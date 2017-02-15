################################################################################
#
#   Name:        compare_vmstat.py
#   Authors:     James H. Loving
#   Description: This script is used to compare two experimental groups' CPU
#                and memory utilization, as measured with vmstat.
#
################################################################################

import argparse
import plotly.plotly as py
from plotly.graph_objs import *
from plotly import tools
import math
from scipy import stats
import numpy as np
from sys import maxsize as MAXSIZE

def clargs():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('dirs',
                        nargs = '*',
                        type = str,
                        help = 'A list of directories to compare, with the OUT directory appended.')

    return parser.parse_args()



def get_sanitized_dirs(dirs):
    sanitized_dirs = []

    for d in dirs:
        if (d[-1] == '/'):
            sanitized_dirs.append(d)
        else:
            sanitized_dirs.append(str(d + '/'))
    
    return sanitized_dirs



def get_data(dirs, header_len):
    data = []
    headers = []

    # get data and headers from the listed directories
    for d in dirs:
        headers.append(d[6:6+header_len])
        infile = d + 'vmstat.txt'
        with open(infile) as f:
            lines = f.readlines()
        entry = {'mem': [], 'cpu':[]}
        for l in lines[7:]:
            entry['mem'].append(int(float(l.split()[3])))
            entry['cpu'].append(100 - int(float(l.split()[-5])))
        data.append(entry)

    # normalize the sample size
    min_mem_len = MAXSIZE
    min_cpu_len = MAXSIZE
    for entry in data:
        if len(entry['mem']) < min_mem_len:
            min_mem_len = len(entry['mem'])
        if len(entry['cpu']) < min_cpu_len:
            min_cpu_len = len(entry['cpu'])
    for entry in data:
        entry['mem'] = entry['mem'][:min_mem_len]
        entry['cpu'] = entry['cpu'][:min_cpu_len]

    return (data, headers)



def print_desc(data, headers, col_width, var):
    print('\n\n{} (Descriptive Statistics):'.format(var.upper()))

    header = ''
    for d in range(len(data)):
        header += headers[d].rjust(col_width + 2)
    
    print(''.ljust(col_width) + header)

    print('Mean:'.ljust(col_width), end='')
    for entry in data:
        print(str(math.ceil(np.mean(entry[var])*100-0.5)/100).rjust(col_width + 2), end='')

    print('')
    print('Std Dev:'.ljust(col_width), end='')
    for entry in data:
        print(str(math.ceil(np.std(entry[var])*100-0.5)/100).rjust(col_width + 2), end='')



def print_ttests(data, headers, col_width, var):
    print('\n\n{} (Paired T-Tests):'.format(var.upper()))

    header = ''
    for d in range(len(data)):
        header += headers[d].rjust(col_width + 2)
    
    print(''.ljust(col_width) + header)
    
    for row in range(len(data)):
        print(headers[row].ljust(col_width), end='')
        for col in range(len(data)):
            if (row == col):
                print('-'.rjust(col_width + 2), end='')
            else:
                try:
                    print(('t=' + str(math.ceil(stats.ttest_rel(data[row][var], data[col][var])[0]*100-0.5)/100) + ',p=' + str(math.ceil(stats.ttest_rel(data[row][var], data[col][var])[1]*100-0.5)/100)).rjust(col_width + 2), end='')
                except:
                    print(('t=' + str(math.ceil(stats.ttest_ind(data[row][var], data[col][var])[0]*100-0.5)/100) + ',p=' + str(math.ceil(stats.ttest_ind(data[row][var], data[col][var])[1]*100-0.5)/100)).rjust(col_width + 2), end='')
        print('')



def get_pretty_headers(headers):
    pretty_headers = []

    for header in headers:
        if 'off' in header:
            pretty_headers.append('EDICT Disabled')
        if 'on-noUI' in header:
            pretty_headers.append('EDICT Enabled, UI Disabled')
        if 'on-yesUI' in header:
            pretty_headers.append('EDICT Enabled, UI Enabled')

    return pretty_headers



def get_pretty_title(var):
    if var == 'mem':
        return 'Free Memory (KB)'
    if var == 'cpu':
        return 'CPU Utilization (%)'



def get_yaxis_scale(var):
    if var == 'mem':
        return [0,500000]
    if var == 'cpu':
        return [0,100]



def output_graphs(data, headers, var, outdir):
    x = list(range(1, len(data[0][var])+1))

    scatters = []
    for d in range(len(data)):
        scatters.append(Scatter(x = x,
                                y = data[d][var],
                                showlegend = False,))

    graph_fig = tools.make_subplots(rows=1,
                                    cols=len(scatters),
                                    shared_yaxes = False,
                                    subplot_titles = tuple(get_pretty_headers(headers)))
    i = 0
    for scatter in scatters:
        i += 1
        graph_fig.append_trace(scatter, 1, i)

    #graph_data = Data(scatters)

    graph_layout = Layout(height=600,
                          width=1800,
                          titlefont=dict(size=24),
                          font=dict(family='Computer Modern Roman, serif', size=18),
                          xaxis1 = XAxis(title = 'Time (s)',
                                         dtick = 600,
                                         range = [1,3600]),
                          xaxis2 = XAxis(title = 'Time (s)',
                                         dtick = 600,
                                         range = [1,3600]),
                          xaxis3 = XAxis(title = 'Time (s)',
                                         dtick = 600,
                                         range = [1,3600]),
                          yaxis1 = YAxis(title = get_pretty_title(var),
                                        range = get_yaxis_scale(var)),
                          yaxis2 = YAxis(range = get_yaxis_scale(var)),
                          yaxis3 = YAxis(range = get_yaxis_scale(var)),)

    graph_fig['layout'].update(graph_layout)

    #fig = Figure(data=graph_data, layout=graph_layout)

    outfile = outdir + var + '.png'
    py.image.save_as(graph_fig, filename=outfile)



def main():
    args = clargs()

    sanitized_dirs = get_sanitized_dirs(args.dirs)

    col_width = 20
    
    (data, headers) = get_data(sanitized_dirs[:-1], col_width)

    py.sign_in('jameshloving', 'gtcGiWGJpgnSKIBgXFqj')

    var_list = ['mem', 'cpu']
    for var in var_list:
        print_desc(data, headers, col_width, var)
        print_ttests(data, headers, col_width, var)
        output_graphs(data, headers, var, sanitized_dirs[-1])

    return



if __name__ == '__main__':
    main()
