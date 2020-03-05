
import argparse
import os
import pandas as pd

parser = argparse.ArgumentParser(description = "transform excel file\n")
parser.add_argument("-e","--excel",help="import excel file\n")
parser.add_argument("-o","--outdir",help="output directory\n")
args =  parser.parse_args()

if not os.path.exists(args.outdir):
    os.mkdir(args.outdir)

sheet_list = pd.read_excel(args.excel,sheet_name = None, index_col = 0)
for num in sheet_list:
    sheet_list[num].to_csv(args.outdir  +"/" +  num +  ".txt", encoding = 'utf-8')




	
