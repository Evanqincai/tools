
import argparse
import os
import pandas as pd
import sys
import xlwings as xw
#################################################################sub function 
def Merge (args):
    if not os.path.exists(args.indir):
        print ("Please import input directory\n");
        sys.exit()
    if not os.path.exists(args.outdir):
        os.mkdir(args.outdir)

    writer = pd.ExcelWriter(args.outdir + "/" + args.prefix + '.xlsx')
    for root,dirs,files in os.walk(args.indir):
        for file in files:
            pathfile = os.path.join(root,file)
            filesize = os.path.getsize(pathfile)
            filename = os.path.splitext(file)[0]
            if (filesize != 0):
                if file.endswith('.txt'):
                    file_content = pd.read_csv(pathfile,index_col = 0 ,sep = "\t",header = 0)
                elif file.endswith('.xls'):
                    file_content = pd.read_excel(pathfile,index_col = 0 ,sep = "\t",header = 0)
                elif file.endswith('.xlsx'):
                    file_content = pd.read_excel(pathfile,index_col = 0 ,sep = "\t",header= 0)
                else:
                    continue
                file_content.to_excel(writer,filename,header=True)
            else:
                print("The\t"+filename+"\tfile\tempty") 
    writer.save()
    writer.close()

def Split (args):
    if not os.path.exists(args.outdir):
        os.mkdir(args.outdir)
    sheet_list = pd.read_excel(args.excel,sheet_name = None, index_col = 0 ,
                               header = None)
    for num in sheet_list:
        sheet_list[num].to_csv(args.outdir  +"/" +  num +  ".txt", 
                               encoding = 'utf-8',sep = "\t",header = False )


################################################################# parameter
Parser = argparse.ArgumentParser(description="File split and merge\n")
subparsers = Parser.add_subparsers(help = "Create sub command")

Parser_a = subparsers.add_parser('Merge',help = "Merge file")
Parser_a.add_argument("-I","--indir",help="input directory\n")
Parser_a.add_argument("-O","--outdir",help="output directory\n")
Parser_a.add_argument("-P","--prefix",help="output file prefix\n")
Parser_a.set_defaults(func = Merge)

Parser_s = subparsers.add_parser('Split',help = "Split file")
Parser_s.add_argument("-e","--excel",help="import excel file\n")
Parser_s.add_argument("-o","--outdir",help="output directory\n")
Parser_s.set_defaults(func = Split)

args = Parser.parse_args()
args.func(args)
