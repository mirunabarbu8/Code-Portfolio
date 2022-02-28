Sample R Markdown document
================
Miruna Barbu
28/02/2022

### A sample RMarkdown title

This RMarkdown file is a sample to demonstrate how to create
results/data presentation in this mode.

#### Examples of image and result presentation in R Markdown

" {.tabset} " is a useful command that permits the use of tabs in
RMarkdown. This helps to reduce the overall length of the document.

##### Tab information

You can choose to have an “initial” tab to provide information of what
is in the next tabs. I do this to shorten the length of the document and
to provide a clear introduction to what is presented.

For instance, in the following tabs there are:

1.  Image presentation in R Markdown.
2.  Table presentation in R Markdown.
3.  Data analysis presentation and results table in R Markdown.

##### Example of an image presentation in RMarkdown

The image below was obtained from [Google
Images](https://www.google.com/search?q=puppies&sxsrf=APq-WBsvg2UEhJzz0R4VDsZAcSuQwMdCKA:1646054927337&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjJxeW5wKL2AhWEUcAKHdgYDVUQ_AUoAXoECAMQAw&biw=1320&bih=769&dpr=2.5#imgrc=Xlf4qHwbPczmKM).

<img src="./puppies.jpg" width="60%" style="display: block; margin: auto;" />

##### Example of a table presentation in RMarkdown

The table below is one created for the purposes of this document. It
uses “pander” to display the table in RMarkdown. It presents the size of
5 dog breeds, randomly selected from
[here](https://www.akc.org/expert-advice/nutrition/breed-weight-chart/).

|    Dog breed    | Female size  |  Male size   |
|:---------------:|:------------:|:------------:|
| German Shepherd | 50-70 pounds | 65-90 pounds |
|  Basset hound   | 40-65 pounds | 40-65 pounds |
|    Bulldogs     |  40 pounds   |  50 pounds   |
|   Dalmatians    | 45-70 pounds | 45-70 pounds |
|      Pugs       | 14-18 pounds | 14-18 pounds |

Female and Male size across 5 dog breeds.

##### Sample of data analysis & results

The script below contains a simple analysis (food consumption in kg
based on dog size) used to illustrate how to conduct analysis and
present results in an RMarkdown file. All data was created simply for
the purpose of this tutorial.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>
Results indicating food consumption as a function of dog size.
</caption>
<thead>
<tr>
<th style="text-align:left;">
Estimate
</th>
<th style="text-align:left;">
Std. Error
</th>
<th style="text-align:left;">
t value
</th>
<th style="text-align:left;">
Pr(&gt;\|t\|)
</th>
<th style="text-align:left;">
result
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;font-weight: bold;color: green !important;">
51.6627274014844
</td>
<td style="text-align:left;font-weight: bold;color: green !important;">
6.2946676825774
</td>
<td style="text-align:left;font-weight: bold;color: green !important;">
8.20737964364319
</td>
<td style="text-align:left;font-weight: bold;color: green !important;">
1.07215459615503e-10
</td>
<td style="text-align:left;font-weight: bold;color: green !important;">
Intercept
</td>
</tr>
<tr>
<td style="text-align:left;">
3.8084342379499
</td>
<td style="text-align:left;">
9.08557020248824
</td>
<td style="text-align:left;">
0.419173937691538
</td>
<td style="text-align:left;">
0.676959022756003
</td>
<td style="text-align:left;">
Food consumption as a function of dog size
</td>
</tr>
</tbody>
</table>

#### 

And now we end the tabset with " {-} "

#### General information

You can run multiple statistical tests in chunks as above and even
create your own tables based on results. You can get more information
from the following resources:

1.  [R Markdown
    cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/).
2.  [R Markdown
    cheatsheet](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf).
3.  [R Markdown
    introduction](https://rmarkdown.rstudio.com/lesson-1.html).
