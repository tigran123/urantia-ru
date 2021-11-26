<?php
ini_set('memory_limit','300M');
$metrics = json_decode(file_get_contents("metrics-short.json"));
$out = sprintf("fb2/test.fb2");
system("cp -f fb2/header.txt fb2/test.fb2");
for ($i = 0; $i <= 196; $i++) {
   $olines = [];
   $pmetrics = $metrics[$i];
   $filename = sprintf("u8/rusnys2006_exemplar_p%03d.u8", $i);
   $lines = file($filename);
   if ($lines == FALSE) {
      printf("ERROR OPENING FILE: %s\n", $filename);
      exit(1);
   }
   if ($i == 32) {
      $olines[] = '</section><section>';
      $olines[] = file_get_contents("fb2/part2.txt");
   } elseif ($i == 57) {
      $olines[] = '</section><section>';
      $olines[] = file_get_contents("fb2/part3.txt");
   } elseif ($i == 120) {
      $olines[] = '</section><section>';
      $olines[] = file_get_contents("fb2/part4.txt");
   }
   $title = str_replace('{{{br}}}', '.', explode("]|", $lines[0], 2));
   $olines[] = '<section><title><p>'.mb_strtoupper($title[1]).'</p></title>';
   $lines = array_slice($lines, 1); /* skip the first line */
   foreach($lines as $linenum => $line) {
       $line_data = explode("]|", $line, 2);
       $line_data = rtrim(convert_tags($line_data[1]));
       if (isset($line_data[1])) {
          if (isset($pmetrics[$linenum])) {
             list($sec, $par, $type) = $pmetrics[$linenum];
             if ($type == 'TEXTP')
                $text = '<p><sup>'.$i.':'.$sec.'.'.$par.'</sup> §§ '.$line_data.'</p>'.PHP_EOL;
                //$text = '<p>'.$line_data.'</p>'.PHP_EOL;
             elseif ($type == 'TEXT')
                $text = '<p><sup>'.$i.':'.$sec.'.'.$par.'</sup> '.$line_data.'</p>'.PHP_EOL;
                //$text = '<p>'.$line_data.'</p>'.PHP_EOL;
             elseif ($type == 'HEADER')
                $text = '<empty-line/><subtitle><p><strong>'.mb_strtoupper($line_data).'</strong></p></subtitle>'.PHP_EOL;
             elseif ($type == 'XHEADER')
                $text = '<empty-line/><subtitle><p><strong>'.mb_strtoupper($line_data).'</strong></p>';
             elseif ($type == 'MIDTITLE')
                $text = '<p><strong>'.mb_strtoupper($line_data).'</strong></p>';
             elseif ($type == 'SUBTITLE')
                $text = '<p><strong>'.mb_strtoupper($line_data).'</strong></p></subtitle>'.PHP_EOL;
             else
                printf("UNKNOWN TYPE IN METRICS! File: %s, linenum=%d\n", $filename, $linenum);
             $olines[] = $text;
          } else
             printf("CORRUPTED METRICS! File: %s, linenum=%d\n", $filename, $linenum);
       } else
          printf("CORRUPTED DATA! File: %s, linenum=%d\n", $filename, $linenum);
   }
   $olines[] = '</section>';
   file_put_contents($out, $olines, FILE_APPEND);
}
file_put_contents($out, '</section></body>', FILE_APPEND);
system("cat fb2/cover.dat >> fb2/test.fb2");

function convert_tags($text) {
   $search = ['{i{i{', '}i}i}'];
   $replace = ['<emphasis>', '</emphasis>'];
   return str_replace($search, $replace, $text);
}
?>
