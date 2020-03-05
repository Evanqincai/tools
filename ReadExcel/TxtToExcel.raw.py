
import argparse
import os
import pandas as pd
import sys

Parser = argparse.ArgumentParser(description="combine Excel file from directory file\n")
Parser.add_argument("-i","--indir",help="input directory\n")
Parser.add_argument("-o","--outdir",help="output directory\n")
Parser.add_argument("-p","--prefix",help="output file prefix\n")
args = Parser.parse_args()


if not os.path.exists(args.indir):
    print ("Please import input directory\n");
    sys.exit()

if not os.path.exists(args.outdir):
    os.mkdir(args.outdir)

writer = pd.ExcelWriter(args.outdir + "/" + args.prefix + '.xlsx')
for root,dirs,files in os.walk(args.indir):
    for file in files:
        pathfile = os.path.join(root,file)
        filename = os.path.splitext(file)[0]
        print(file)
        if file.endswith('.txt'):
            file_content = pd.read_csv(pathfile)
        elif file.endswith('.xls'):
            file_content = pd.read_excel(pathfile)
        elif file.endswith('.xlsx'):
            file_content = pd.read_excel(pathfile)

        file_content.to_excel(writer,filename)
writer.save()



            
        
        
