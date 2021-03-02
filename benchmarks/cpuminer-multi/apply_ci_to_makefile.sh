#!/bin/bash

update_rule_ci() 
{
  gawk -v obj_name=$1 \
      'BEGIN {
        i=0;
        name = substr(obj_name, 1, length(obj_name)-2)
        ofile_name = sprintf("%s:", obj_name)
        obj_filename = sprintf("%s.obj:", name)
        llvm_obj_name = sprintf("llvm_%s.ll", name)
        opt_obj_name = sprintf("opt_%s.ll", name)
        lc_obj_name = sprintf("%s.ll", name)
      }
      $1~ofile_name && $1!~obj_filename {
        print
        i=1;
      }
      $1!~ofile_name {
        if(i==1) 
        {
          printf("\t%s",$1); printf(" -S -emit-llvm "); 
          j=0; 
          for(i=2;i<=NF;++i) 
          { 
            if(match($i, obj_name)!=0) 
            {
              llvm_obj=gensub(obj_name, llvm_obj_name, "g", $i)
              opt_obj=gensub(obj_name, opt_obj_name, "g", $i)
              lc_obj=gensub(obj_name, lc_obj_name, "g", $i)
              obj=$i
              printf("%s ", llvm_obj)
            }
            else
            {
              printf("%s ", $i)
            }
          }; 
          printf("\n");
          printf("\t$(CC_OPT) $(OPTFLAGS) -S < %s > %s\n", llvm_obj, opt_obj)
          printf("\t$(CC_OPT) $(LCFLAGS) -S < %s > %s\n", opt_obj, lc_obj)
          printf("\t$(CC_LLC) -relocation-model=pic -filetype=obj -o %s `test -f '\''%s'\'' || echo '\'\$\(srcdir\)/'\'\''`%s\n", obj, lc_obj, lc_obj)
          i=0;
        }
        else {
          print
        }
      }
      ' \
  $out_file > tmp
  mv tmp $out_file
#      {print}' \
#      ' \
#llvm_obj_name = gensub("\.o",".ll", "g", $i)
}

update_rule_orig() 
{
  gawk -v obj_name=$1 \
      'BEGIN {
        i=0;
        name = substr(obj_name, 1, length(obj_name)-2)
        ofile_name = sprintf("%s:", obj_name)
        obj_filename = sprintf("%s.obj:", name)
        llvm_obj_name = sprintf("llvm_%s.ll", name)
        opt_obj_name = sprintf("opt_%s.ll", name)
      }
      $1~ofile_name && $1!~obj_filename {
        print
        i=1;
      }
      $1!~ofile_name {
        if(i==1) 
        {
          printf("\t%s",$1); printf(" -S -emit-llvm "); 
          j=0; 
          for(i=2;i<=NF;++i) 
          { 
            if(match($i, obj_name)!=0) 
            {
              llvm_obj=gensub(obj_name, llvm_obj_name, "g", $i)
              opt_obj=gensub(obj_name, opt_obj_name, "g", $i)
              obj=$i
              printf("%s ", llvm_obj)
            }
            else
            {
              printf("%s ", $i)
            }
          }; 
          printf("\n");
          printf("\t$(CC_OPT) $(OPTFLAGS) -S < %s > %s\n", llvm_obj, opt_obj)
          printf("\t$(CC_LLC) -relocation-model=pic -filetype=obj -o %s `test -f '\''%s'\'' || echo '\'\$\(srcdir\)/'\'\''`%s\n", obj, opt_obj, opt_obj)
          i=0;
        }
        else {
          print
        }
      }
      ' \
  $out_file > tmp
  mv tmp $out_file
#      {print}' \
#      ' \
#llvm_obj_name = gensub("\.o",".ll", "g", $i)
}

#cp Makefile.lc tmp1
#update_rule "cpuminer-api.o"
#exit

if [ $# -ne 1 ]; then
  echo "Usage: ./apply_ci_to_makefile.sh <0-ci, 1-orig>"
  exit
fi

if [ $1 -eq 1 ]; then
  echo "Generating LLVM compliant Makefile for Orig mode"
  array_obj=`grep "\.o:" Makefile.lc | grep -ve ".cpp\|\.c\.o\|\.S\.o\|^#\|.S$\|ci_lib.o" \
          | awk '{pos=match($1,"/"); printf("%s ", substr($1,pos+1,length($1)-pos-1))}'`
  in_file="Makefile"
  git checkout $in_file
  out_file="Makefile.orig"
else
  echo "Generating LLVM compliant Makefile for CI mode"
  array_obj=`grep "\.o:" Makefile.lc | grep -ve ".cpp\|\.c\.o\|\.S\.o\|^#\|.S$\|ci_lib.o\|cpuminer-cpu-miner.o\|cpuminer-util.o" \
          | awk '{pos=match($1,"/"); printf("%s ", substr($1,pos+1,length($1)-pos-1))}'`
  in_file="Makefile.lc"
  out_file="tmp1"
fi

cp $in_file $out_file
for obj in $array_obj
do
  echo $obj
  if [ $1 -eq 1 ]; then
    update_rule_orig $obj
  else
    update_rule_ci $obj
  fi
done
#update_rule "cpuminer-sph_keccak.o"
