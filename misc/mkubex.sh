#!/bin/bash

#
# Generate html source files for Urantia Book Explorer from UBDS exemplar and metric files.
#

METRIC_FILE=metrics/exemplarmap.js
DATA_DIR=u8-notags
FILE_PREFIX=rusnys2006_exemplar
PARCLUSTER_FILE=StandardizedParagraphBreaks.txt
PAPER_AUTHORS=paper-authors.txt
OUT=ubex
TOC=$OUT/toc.html

declare -a parlist lineid linetype
declare -i sec i paridx linenum

./convert-tags-ubex.sh

rm -rf $OUT ; mkdir -p $OUT
echo -E "<ul class='toc' id='toc5'>" > $TOC
echo -E "<li title='<i>Представлено при содействии Уверсского Отряда личностей сверхвселенной, действующего с разрешения Древних Дней Орвонтона.</i>'><a href=\".U0_0_1\"><b>I. ЦЕНТРАЛЬНАЯ ВСЕЛЕННАЯ И СВЕРХВСЕЛЕННЫЕ</b></a>" >> $TOC
echo -E " <ul>" >> $TOC

for ((i = 0; i <= 196; i++));
do
   if ((i == 32)) ; then
      echo -E " </ul>" >> $TOC
      echo -E "</li>" >> $TOC
      echo -E "<li title='<i>Представлено при содействии Небадонского Отряда личностей локальной вселенной, действующих с разрешения Гавриила Спасоградского.</i>'><a href=\".U32_0_1\"><b>II. ЛОКАЛЬНАЯ ВСЕЛЕННАЯ</b></a>" >> $TOC
      echo -E " <ul>" >> $TOC
   fi
   if ((i == 57)) ; then
      echo -E " </ul>" >> $TOC
      echo -E "</li>" >> $TOC
      echo -E "<li title='<i>Эти тексты были представлены при содействии Отряда личностей локальной вселенной, действующих с разрешения Гавриила Спасоградского</i>'><a href=\".U57_0_1\"><b>III. ИСТОРИЯ УРАНТИИ</b></a>" >> $TOC
      echo -E " <ul>" >> $TOC
   fi
   if ((i == 120)) ; then
      echo -E " </ul>" >> $TOC
      echo -E "</li>" >> $TOC
      echo -E "<li title='<i>Материалы этой части подготовлены комиссией из 12 срединников Урантии, работавшей под началом Мелхиседека, руководителя комиссии по откровениям.<br>Основные данные о событиях сообщены срединником второго рода, который некогда был назначен сверхчеловеческим хранителем апостола Андрея</i>'><a href=\".U120_0_1\"><b>IV. ЖИЗНЬ И УЧЕНИЯ ИИСУСА</b></a>" >> $TOC
      echo -E " <ul>" >> $TOC
   fi
   p=$(printf "%03d" $i)
   parlist=($(sed -ne "s%^/\* Paper${i} \*/  *\[\(.*\)\],*%\1%p" ${METRIC_FILE} | sed -e "s%,%%g"))
   numsec=${#parlist[@]}
   echo "paper $p: ($numsec sections)"
   linenum=0
   lineid=()
   linetype=()
   for ((sec = 0; sec < $numsec; sec++));
   do
      for ((paridx = 0; paridx <= parlist[$sec]; paridx++));
      do
         if ((i == 0 && sec == 12 && paridx == 10)) ; then
            linetype[$linenum]="sectiontitle"
         fi
         if ((paridx == 0)) ; then
            linetype[$linenum]="sectiontitle"
            if ((sec == 0)) ; then
               linetype[$linenum]="papertitle"
            fi
         fi
         if ((i == 139 && sec > 9)) ; then
            lineid[$linenum]="p$p $((sec+1)):${paridx}"
         elif ((i == 144)); then
            if ((sec == 5 && paridx >= 11 && paridx <= 23)); then
               lineid[$linenum]="p$p ${sec}:$((paridx+1))"
            elif ((sec == 5 && paridx >= 24 && paridx <= 35)); then
               lineid[$linenum]="p$p ${sec}:$((paridx+2))"
            elif ((sec == 5 && paridx >= 36 && paridx <= 50)); then
               lineid[$linenum]="p$p ${sec}:$((paridx+3))"
            elif ((sec == 5 && paridx >= 51 && paridx <= 68)); then
               lineid[$linenum]="p$p ${sec}:$((paridx+4))"
            elif ((sec == 5 && paridx >= 69 && paridx <= 81)); then
               lineid[$linenum]="p$p ${sec}:$((paridx+5))"
            elif ((sec == 5 && paridx >= 82)); then
               lineid[$linenum]="p$p ${sec}:$((paridx+6))"
            else
               lineid[$linenum]="p$p ${sec}:${paridx}"
            fi
         else
            lineid[$linenum]="p$p ${sec}:${paridx}"
         fi
         ((linenum++))
      done
   done
   linenum=0
   >$OUT/p${p}.html
   while read -r line
   do
      text=$(echo -E "$line" | sed -e "s%^\[[0-9][0-9]*\]| *%%")
      chap=$(echo "${lineid[$linenum]}" | sed -ne "s%p... \([0-9][0-9]*\):[0-9][0-9]*%\1%p")
      verse=$(echo "${lineid[$linenum]}" | sed -ne "s%p... [0-9][0-9]*:\([0-9][0-9]*\)%\1%p")
      if [ "${linetype[$linenum]}" = "papertitle" ] ; then
         papertitle=$(echo -E "$text" | sed -ne "s%^Текст [0-9][0-9]*.. \(.*\)$*$%\1%p")
         author=$(grep "${p}" ${PAPER_AUTHORS} | sed 's/^p...://')
         echo -E "    </ul>" >> $OUT/toc.html
         echo -E "  </li>" >> $OUT/toc.html
         if ((i == 0)) ; then
            echo -E "  <li title='<i>$author</i>'><a class="U${i}_${chap}_1" href=".U${i}_${chap}_1"><b>Предисловие</b></a>" >> $OUT/toc.html
         else
            echo -E "  <li title='<i>$author</i>'><a class="U${i}_${chap}_1" href=".U${i}_${chap}_1"><b>$i. $papertitle</b></a>" >> $OUT/toc.html
         fi
         echo -E "    <ul>" >> $OUT/toc.html
      else
         if [ "${linetype[$linenum]}" = "sectiontitle" ] ; then
            echo -E "      <li><a class=\"U${i}_${chap}_${verse}\" href=\".U${i}_${chap}_${verse}\">$text</a></li>" >> $OUT/toc.html
            echo -E "<h4><a class=\"U${i}_${chap}_${verse}\" href=\".U${i}_${chap}_${verse}\">$text</a></h4>" >> $OUT/p${p}.html
         else
            if grep -q " $i:$chap.$((verse-1))$" ${PARCLUSTER_FILE} && [[ ! "$text" =~ ^[0-9][0-9]*\. ]] ; then
               echo -E "<p><a class=\"U${i}_${chap}_${verse}\" href=\".U${i}_${chap}_${verse}\"><sup>${i}:${chap}.${verse}</sup></a> §§ ${text}" >> $OUT/p${p}.html
            else
               echo -E "<p><a class=\"U${i}_${chap}_${verse}\" href=\".U${i}_${chap}_${verse}\"><sup>${i}:${chap}.${verse}</sup></a> ${text}" >> $OUT/p${p}.html
               if ((i == 144)); then
                  if (($chap == "5" && $verse == "10")); then
                     echo -E "<h4><a class=\"U144_5_11\" href=\".U144_5_11\">***</a></h4>" >> $OUT/p${p}.html
                  elif (($chap == "5" && $verse == "24")); then
                     echo -E "<h4><a class=\"U144_5_25\" href=\".U144_5_25\">***</a></h4>" >> $OUT/p${p}.html
                  elif (($chap == "5" && $verse == "37")); then
                     echo -E "<h4><a class=\"U144_5_38\" href=\".U144_5_38\">***</a></h4>" >> $OUT/p${p}.html
                  elif (($chap == "5" && $verse == "53")); then
                     echo -E "<h4><a class=\"U144_5_54\" href=\".U144_5_54\">***</a></h4>" >> $OUT/p${p}.html
                  elif (($chap == "5" && $verse == "72")); then
                     echo -E "<h4><a class=\"U144_5_73\" href=\".U144_5_73\">***</a></h4>" >> $OUT/p${p}.html
                  elif (($chap == "5" && $verse == "86")); then
                     echo -E "<h4><a class=\"U144_5_87\" href=\".U144_5_87\">***</a></h4>" >> $OUT/p${p}.html
                  fi
               fi
            fi
         fi
      fi
      ((linenum++))
   done < ${DATA_DIR}/${FILE_PREFIX}_p${p}.u8
done
echo -E " </ul>" >> $TOC
echo -E "</li>" >> $TOC
echo -E "</ul>" >> $TOC
