################################################################################
#
#   Name:        graph_iperf.py
#   Authors:     James H. Loving
#   Description: This script is used to graph the router's throughput, as
#                measured by an iperf test between a client and a server.
#
################################################################################

import argparse
import plotly.plotly as py
from plotly.graph_objs import *

def clargs():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('infile',
                        type = str,
                        help = 'The input file (from iperf).')
    parser.add_argument('outfile',
                        type = str,
                        help = 'The output file (for the graph).')

    return parser.parse_args()



def main():
    args = clargs()

    y = []

    with open(args.infile) as f:
        for line in f:
            if line.split()[0] == "[SUM]":
                y.append(int(line.split()[-2]))

    x = list(range(1, len(y)+1))     

    py.sign_in('jameshloving', 'gtcGiWGJpgnSKIBgXFqj')

    data = Data([Scatter(x = x,
                         y = y,
                         line = Line(),
                         name = 'Throughput',)])

    layout = Layout(autosize = True,
                    xaxis = XAxis(title = 'Time (s)'),
                    yaxis = YAxis(title = 'Throughput (MBits/s)',
                                  range = [0,1000]))

    fig = Figure(data=data, layout=layout)
    py.image.save_as(fig, filename=args.outfile)

    return



if __name__ == '__main__':
    main()
