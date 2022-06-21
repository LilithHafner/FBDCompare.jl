import numpy as np
import numpy.random as rng
import scipy.special
from AliasTable import parse_alias_table
import argparse

#implements https://arxiv.org/pdf/2006.07060.pdf
#thousands of times faster than https://github.com/manhtuando97/KDD-20-Hypergraph/blob/master/Code/Generator/hyper_preferential_attachment.py

def hyper_pa(degree_distribution, edgesize_distribution, max_edgesize, nodes):
    edges = [[a,a+1] for a in range(1,max_edgesize,2)]
    edges_by_size = [[] for _ in range(max_edgesize+1)]
    edges_by_size[2] = edges.copy()

    cum_sum_source = np.zeros(max_edgesize, dtype=np.int64)

    # binomial_table = np.zeros((max_edgesize+1,max_edgesize), dtype=np.int64)
    # for a in range(max_edgesize+1):
    #     for b in range(max_edgesize):
    #         binomial_table[a,b] = scipy.special.binom(a, b)

    for n in range(edges[-1][-1]+1,nodes+1):
        for _ in range(degree_distribution.sample()):
            new_edgesize = edgesize_distribution.sample()
            new_edge = [n]*new_edgesize

            if new_edgesize > 1:
                binom = 1
                acc = 0
                cum_sum = cum_sum_source[new_edgesize-2:max_edgesize-1] #13%
                for extra in range(len(cum_sum)):
                    source_edgesize = new_edgesize-1+extra
                    # binom = binomial_table[source_edgesize,new_edgesize-1]
                    acc += len(edges_by_size[source_edgesize])*binom
                    cum_sum[extra] = acc
                    binom = binom*(source_edgesize+1)//(source_edgesize-new_edgesize+2)
                total = cum_sum[-1]
                if total == 0:
                    new_edge[1:] = rng.choice(range(1,n), new_edgesize-1, replace=False)
                else:
                    key = rng.randint(1,total+1)
                    extra = 0
                    while cum_sum[extra] < key:
                        extra += 1
                    source_edgesize = new_edgesize-1+extra
                    #Huzzah! we have a source edgesize!

                    es = edges_by_size[source_edgesize]
                    source_edge = es[rng.randint(len(es))]

                    #Huzzah! and a specific source edge

                    # We represent edges as sets. The order returned is arbitrary, so it is
                    # okay to partially shuffle here:
                    rng.shuffle(source_edge)
                    new_edge[1:] = source_edge[:new_edgesize-1]

                    #Huzzah! and an actual edge to use
            edges.append(new_edge)
            assert len(new_edge) == new_edgesize
            edges_by_size[new_edgesize].append(new_edge)
    return edges

if __name__ == "__main__":
    # \/ Argument parsing adapted from from ../hyper_pa/hyper_preferential_attachment.py \/
    parser = argparse.ArgumentParser(description="HyperPA arguments.")

    parser.add_argument('--name', dest='name', help='name of the dataset')
    parser.add_argument('--num_nodes', dest='nodes', type=int, help='number of nodes in the hypergraphs')

    parser.add_argument('--size_distribution_directory', dest='size_distribution_directory', help='directory containing the size distribution file')
    parser.add_argument('--simplex_per_node_directory', dest='simplex_per_node_directory', help='directory containing the distribution of hyperedges per new node')

    parser.add_argument('--file_name', dest='file_name', help='name of the output file')
    parser.add_argument('--output_directory', dest='output_directory', help='directory containing the output file')

    parser.set_defaults(size_distribution_directory='size distribution',
                        simplex_per_node_directory='simplex per node',
                        output_directory='output')

    args = parser.parse_args()
    # /\ Argument parsing adapted from from ../hyper_pa/hyper_preferential_attachment.py /\

    degree_distribution = parse_alias_table(args.simplex_per_node_directory + "/" + args.name + "-simplices-per-node-distribution.txt")
    edgesize_distribution = parse_alias_table(args.size_distribution_directory + "/" + args.name + " size distribution.txt")
    max_edgesize = max(edgesize_distribution.values)
    nodes = args.nodes

    output = hyper_pa(degree_distribution, edgesize_distribution, max_edgesize, nodes)

    with open(args.output_directory + "/" + args.file_name + ".txt", "w") as f:
        for edge in output:
            f.write(" ".join(str(node) for node in edge) + "\n")