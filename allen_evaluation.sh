#!/bin/bash

# Usage:
# ./allen_evaluation.sh


#base_dir=/Users/guru/MyResearch/split_and_rephrase/sprp-logic-acl2019/data/new-websplit
#plain_dir=${base_dir}/rte/main-test-random-org-nob-100
#fileprefix=rte_random_org-nob

base_dir=/Users/guru/MyResearch/split_and_rephrase/sprp-logic-acl2019/data/new-websplit
plain_dir=${base_dir}/rte/main-test-random-org-nob-100
fileprefix=rte_random_org-nob


# Create a directory named "testset" and put problems and their answer
# (whose prefix is "example"), as in:
# $ ls testset/
# example1.txt			example2.txt
# example1.txt.answer		example2.txt.answer

# Set a result directory
results_dir=pal_results

# # Copy a coq static library and compile it.
# cp en/coqlib_sick.v coqlib.v
# coqc coqlib.v
# cp en/tactics_coq_sick.txt tactics_coq.txt

# Run pipeline for each entailment problem.
#for f in ${plain_dir}/${fileprefix}* ; do #.txt ; do
python allen_sprp_eval.py ${plain_dir} $fileprefix;
#done

# Wait for the parallel processes to finish.
wait

total=0
correct=0
rev_total=0
rev_correct=0

rm ${results_dir}/*tmp;

for f in ${results_dir}/${fileprefix}*.answer ; do #.txt; do 修正が必要
  let total++
  base_filename=${f##*/}
  sys_filename=${results_dir}/${base_filename}
  gold_answer="yes" #`head -1 $f`
  if [ ! -e ${sys_filename} ]; then
    sys_answer="unknown"
  else
    sys_answer=`head -1 ${sys_filename}`
    if [ ! "${sys_answer}" == "unknown" ] && [ ! "${sys_answer}" == "yes" ] && [ ! "${sys_answer}" == "no" ]; then
      sys_answer="unknown"
    fi
  fi
  if [ "${gold_answer}" == "${sys_answer}" ]; then
    let correct++
  fi
  #echo -e $f"\t"$gold_answer"\t"$sys_answer
  labels=`tail -n +2 ${sys_filename}`
  while read line
  do
    let rev_total++
    if [ "yes" == "$line" ]; then
      let rev_correct++
    fi
  done << FILE
$labels
FILE
done

accuracy=`echo "scale=3; $correct / $total" | bc -l`
echo "Accuracy: "$correct" / "$total" = "$accuracy

rev_accuracy=`echo "scale=3; $rev_correct / $rev_total" | bc -l`
echo "rev-Accuracy: "$rev_correct" / "$rev_total" = "$rev_accuracy

total_accuracy=`echo "scale=3; ($correct + $rev_correct) / ($total + $rev_total)" | bc -l`
echo "total Accuracy: ("$correct"+"$rev_correct") / ("$total"+"$rev_total") = "$total_accuracy

echo "Evaluating."
echo "<!doctype html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>Evaluation results of "$templates"</title>
  <style>
    body {
      font-size: 1.5em;
    }
  </style>
</head>
<body>
<table border='1'>
<tr>
  <td>problem</td>
  <td>system answer</td>" > $results_dir/main.html
for parser in `cat en/parser_location.txt`; do
  parser_name=`echo $parser | awk -F':' '{print $1}'`
  echo "<td>"$parser_name"</td>"  >> $results_dir/main.html
done
echo "</tr>" >> $results_dir/main.html

total_observations=0
correct_recognitions=0
attempts=0

red_color="rgb(255,0,0)"
green_color="rgb(0,255,0)"
white_color="rgb(255,255,255)"
gray_color="rgb(136,136,136)"

for f in `ls -v ${results_dir}/${fileprefix}*.answer`; do
  base_filename=${f##*/}
  system_filename=${results_dir}/${base_filename}
  gold_answer="yes"#`cat $gold_filename`
  #system_answer=`head -n 1 $system_filename` #`cat $system_filename`
  total_number=$((total_number + 1))
  color=$white_color
  #if [ "$gold_answer" == "yes" ]; then
    total_observations=$((total_observations + 1))
    if [ "$gold_answer" == "$system_answer" ]; then
      correct_recognitions=$((correct_recognitions + 1))
      color=$green_color
    else
      color=$red_color
    fi
    if [ "$system_answer" == "yes" ] || [ "$system_answer" == "no" ]; then
      attempts=$((attempts + 1))
    else
      color=$gray_color
  #  fi
 fi
  echo '<tr>
  <td>'${base_filename/.answer/}'</td>' >> $results_dir/main.html
    for parser in "" `cat en/parser_location.txt`; do
      if [ ! -z $parser ]; then
        parser_name=`echo $parser | awk -F':' '{print $1}'`"."
      else
#         parser_name=""
#       fi
#       if [ -e ${results_dir}/${base_filename/.answer/}.${parser_name}answer ]; then
#         system_answer=`cat ${results_dir}/${base_filename/.answer/}.${parser_name}answer`
#       else
#         system_answer="error"
#       fi
#       color=$white_color
#       if [ "$gold_answer" == "yes" ] || [ "$gold_answer" == "no" ]; then
#         if [ "$gold_answer" == "$system_answer" ]; then
#           color=$green_color
#         else
#           color=$red_color
#         fi
#       elif [ "$system_answer" == "unknown" ] || [ "$system_answer" == "error" ] || [ "$system_answer" == "undef" ]; then
#         color=$gray_color
#       fi
#       echo '<td><a style="background-color:'$color';" href="'${base_filename/.answer/}.${parser_name}html'">'$system_answer'</a>' >> $results_dir/main.html
#     done
# done
#
# echo '</tr>' >> $results_dir/main.html
# echo "
# <h4><font color="red">Accuracy: "$correct" / "$total" = "$accuracy" </font></h4>
# <h4><font color="red">rev-Accuracy: "$rev_correct" / "$rev_total" = "$rev_accuracy" </font></h4>
# <h4><font color="red">Total Accuracy: ("$correct" + "$rev_correct") / ("$total" + "$rev_total") = "$total_accuracy" </font></h4>
# </body>
# </html>
# " >> $results_dir/main.html
