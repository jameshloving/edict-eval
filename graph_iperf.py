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
    
    parser.add_argument('in4',
                        type = str,
                        help = 'The IPv4 input file (from iperf).')
    parser.add_argument('in6',
                        type = str,
                        help = 'The IPv6 input file (from iperf).')
    parser.add_argument('outfile',
                        type = str,
                        help = 'The output file (for the graph).')

    return parser.parse_args()



def main():
    args = clargs()

    y4 = []
    y6 = []

    with open(args.in4) as f:
        for line in f:
            if line.split()[0] == "[SUM]":
                y4.append(int(line.split()[-2]))

    with open(args.in6) as f:
        for line in f:
            if line.split()[0] == "[SUM]":
                y6.append(int(line.split()[-2]))

    x = list(range(1, len(y4)+1))     

    y_total = [a + b for a, b in zip(y4, y6)]

    py.sign_in('jameshloving', 'gtcGiWGJpgnSKIBgXFqj')

    data = Data([Scatter(x = x,
                         y = y4,
                         line = Line(),
                         mode = 'lines',
                         name = 'IPv4',),
                 Scatter(x = x, 
                         y = y6,
                         line = Line(),
                         mode = 'lines',
                         name = 'IPv6',),
                 Scatter(x = x, 
                         y = y_total,
                         line = Line(),
                         mode = 'lines',
                         name = 'Total',)])

    layout = Layout(autosize = True,
                    xaxis = XAxis(title = 'Time (s)'),
                    yaxis = YAxis(title = 'Throughput (MBits/s)',
                                  range = [0,1000]))

    fig = Figure(data=data, layout=layout)
    py.image.save_as(fig, filename=args.outfile)

    return



if __name__ == '__main__':
    main()
