################################################################################
#
#   Name:        graph_vmstat.py
#   Authors:     James H. Loving
#   Description: This script is used to graph the router's memory and CPU
#                utilization, as measured on the router via vmstat.
#
################################################################################

import argparse
import plotly.plotly as py
from plotly.graph_objs import *

from IPython import embed

def clargs():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('dir',
                        type = str,
                        help = 'The directory to read from and write to.')

    return parser.parse_args()



def main():
    args = clargs()

    if (args.dir[-1] == '/'):
        sanitized_dir = args.dir
    else:
        sanitized_dir = args.dir + '/'

    y_mem = []
    y_cpu = []

    infile = sanitized_dir + 'vmstat.txt'
    with open(infile) as f:
        lines = f.readlines()

    #total_mem = int(lines[4].split()[3])

    for l in lines[7:]:
        y_mem.append(int(float(l.split()[3])))
        #y_mem.append(total_mem - int(l.split()[3]))
        y_cpu.append(100 - int(float(l.split()[-5])))

    x = list(range(1, len(y_mem)+1))     

    py.sign_in('jameshloving', 'gtcGiWGJpgnSKIBgXFqj')

    data = Data([Scatter(x = x,
                         y = y_mem,
                         line = Line(),
                         name = 'Free Memory (KB)',)])
                         #name = 'Memory Utilization (KB)',)])

    layout = Layout(autosize = True,
                    xaxis = XAxis(title = 'Time (s)',
                                  dtick = 600,),
                    yaxis = YAxis(title = 'Free Memory (KB)',
                                  range = [0,128000]))

    fig = Figure(data=data, layout=layout)
    outfile = sanitized_dir + 'mem.png'
    py.image.save_as(fig, filename=outfile)

    data = Data([Scatter(x = x,
                         y = y_cpu,
                         line = Line(),
                         name = 'CPU Utilization (%),')])

    layout = Layout(autosize = True,
                    xaxis = XAxis(title = 'Time (s)',
                                  dtick = 600,),
                    yaxis = YAxis(title = 'CPU Utilization (%)',
                                  range = [0,100],
                                  ticksuffix = '%',))

    fig = Figure(data=data, layout=layout)
    outfile = sanitized_dir + 'cpu.png'
    py.image.save_as(fig, filename=outfile)

    return



if __name__ == '__main__':
    main()
