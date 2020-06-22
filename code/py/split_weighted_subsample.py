#!/usr/local/bin/python3
""" Select weighted subsets of sequences to be used as references and samples for OptiFit """
from collections import defaultdict
import numpy as np
import shutil


def main():
    np.random.seed(int(snakemake.wildcards.seed))
    for src, dest in [
        [snakemake.input.fasta, snakemake.output.fasta],
        [snakemake.input.count, snakemake.output.count],
        [snakemake.input.dist, snakemake.output.dist],
    ]:
        shutil.copyfile(src, dest)

    all_seqs = SeqList.from_files(snakemake.input.fasta, snakemake.input.count, snakemake.input.dist)
    print('all_seqs read')
    sample_size = int(round(float(snakemake.wildcards.sample_frac) * len(all_seqs), 0))
    print(sample_size)
    ref_size = int(round(float(snakemake.wildcards.ref_frac) * len(all_seqs), 0))
    ref_list = all_seqs.get_sample(ref_size, snakemake.wildcards.ref_weight)
    print('ref_list made')
    ref_list.write_ids(snakemake.output.ref_accnos)
    print('ref_list written')
    remaining_seqs = seq_list.set_diff(all_seqs, ref_list)
    print('remaining seqs extracted')
    sample_list = remaining_seqs.get_sample(sample_size, "simple")
    print('sample seqs obtained')
    sample_list.write_ids(snakemake.output.sample_accnos)
    print('sample accnos written')


class MetaSeq:
    def __init__(self, seq_id, avg_abun, avg_dist):
        self.seq_id = seq_id
        self.avg_abun = avg_abun
        self.avg_dist = avg_dist

    @property
    def avg_sim():
        return 1 - avg_dist


class SeqList:
    def __init__(self, seqs):
        self.seqs = seqs

    def __len__(self):
        return len(self.seqs)

    @property
    def ids(self):
        return [seq.seq_id for seq in self.seqs]

    @property
    def scaled_abuns(self):
        total_abun = sum(seq.avg_abun for seq in self.seqs)
        return [seq.avg_abun / total_abun for seq in self.seqs]

    @property
    def scaled_dists(self):
        total_dist = sum(seq.avg_dist for seq in self.seqs)
        return [seq.avg_dist / total_dist for seq in self.seqs]

    @property
    def scaled_sims(self):
        return [dist - 1 for dist in self.scaled_dists]

    @classmethod
    def from_files(cls, fasta_fn, count_fn, dist_fn):
        with open(fasta_fn, "r") as fasta_file:
            seq_dict = {
                line.strip('>').strip(): MetaSeq(line.strip('>').strip(), np.nan, np.nan)
                for line in fasta_file if line.startswith('>')
            }
        with open(count_fn, "r") as count_file:
            line = next(count_file)
            for line in count_file:
                line = line.strip().split("\t")
                seq_id = line[0]
                seq_dict[seq_id].avg_abun = np.mean([float(count) for count in line[1:]])
        with open(dist_fn, "r") as dist_file:
            line = next(dist_file)
            distances = defaultdict(list)
            for line in dist_file:
                line = line.strip().split()
                seq_id1 = line[0]
                seq_id2 = line[1]
                dist = float(line[2])
                distances[seq_id1].append(dist)
                distances[seq_id2].append(dist)
        for seq_id in distances:
            seq_dict[seq_id].avg_dist = np.mean(distances[seq_id])
        print('seqs with nans:')
        print([seq.seq_id for seq in seq_dict.values()])
        return cls(list(sorted(seq_dict.values(), key=lambda seq: seq.seq_id)))

    @classmethod
    def set_diff(cls, lhs, rhs):
        return cls([seq for seq in lhs.seqs if seq.seq_id not in rhs.ids])

    def get_sample(self, sample_size, weight_method):
        random_weight_probs = {
            "simple": None,
            "abundance": self.scaled_abuns,
            "distance": self.scaled_dists,
        }
        sample_seqs = np.random.choice(
            self.seqs,
            replace=False,
            size=sample_size,
            p=random_weight_probs[weight_method],
        )
        return SeqList(sample_seqs)

    def write_ids(self, output_fn):
        with open(output_fn, "w") as outfile:
            for seq_id in self.ids:
                outfile.write(f"{seq_id}\n")


main()
