Parallel Institutions and Civil Resistance
================

What is the impact of parallel institution-building on non-state actors’
strategic campaigns? Non-state campaigns, both violent and nonviolent,
occasionally attempt to develop independent institutions for the
provision of public goods and services and for the execution of
political tasks. In this paper, I employ the Nonviolent and Violent
Campaign Outcomes 2.1 (NAVCO) dataset to measure how building parallel
institutions affects the longevity and success rates of campaigns. Using
survival analysis, I show that education and social welfare institutions
can help campaigns achieve their goals, but that this effect diverges
based on the violence of a campaign.

- [Hypotheses](#Hypotheses)
- [DVs and IVs](#Dependent-and-Independent-Variables)
- [Methods](#Methods)
- [Variable Characteristics](#Variable-Characteristics)
- [Longevity Models](#Longevity-Models)
- [Binomial Logistic Regression](#Binomial-Logistic-Regression)
- [Multinomial Logistic Regression](#Multinomial-Logistic-Regression)
- [Results](#Results)

### Hypotheses

- **Hypothesis 1**: Social welfare and educational institutions help
  political resistance campaigns achieve their goals.
- **Hypothesis 2**: Campaigns with traditional or new media systems last
  longer and have higher rates of success than those without.
- **Hypothesis 3**: Violent campaigns are benefitted by building
  education systems, while nonviolent campaigns are benefitted by social
  welfare systems.

### Dependent and Independent Variables

**DV**: Campaign length; campaign success or failure.

**IV**: Parallel institutions:

- Law Enforcement
- Education
- Social Welfare
- Traditional Media
- New Media
- Courts

Condition:

- Violence or nonviolence of campaign

### Methods

- Random Effects Linear Regression: Campaign Length vs. Parallel
  Institutions
- Binomial Logistic Regression: Campaign Success vs. Parallel
  Institutions
- Multinomial Logistic Regression: Campaign Success OR Failure
  vs. Parallel Institutions
- Competing Risks Survival Analysis: Campaign Success Hazard Rates on
  Parallel Institutions, with Failure as Competing Event

### Variable Characteristics

![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Longevity Models

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Binomial Logistic Regression

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

### Multinomial Logistic Regression

    ## # weights:  78 (50 variable)
    ## initial  value 2074.180001 
    ## iter  10 value 958.250945
    ## iter  20 value 847.912780
    ## iter  30 value 762.639838
    ## iter  40 value 754.566171
    ## iter  50 value 754.435347
    ## iter  60 value 754.419855
    ## final  value 754.417359 
    ## converged

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

### Results

#### Campaign Length

- No independent variable of interest has a clear impact on campaign
  length; educational institutions *may* have a slight conditional
  effect with the violence of the campaign.
- Media coverage shortens campaigns.

#### Campaign Success

- Across all model specifications, education and social welfare have the
  strongest effects on success rates.
- Both competing risks and multinomial logit show that violent campaigns
  are harmed by building social welfare systems and helped by building
  educational systems.
  - These results are significant at least at the .1 level in the
    competing risks regression.
- I replicate previous findings that nonviolent tactics, security force
  defections, campaign size, and campaign support from the regime have
  significant positive effects on success rates. International support
  of the regime and repression of the campaign have significant negative
  impacts.

<object data="https://viewscreen.githubusercontent.com/view/pdf?browser=safari&amp;bypass_fastly=true&amp;color_mode=auto&amp;commit=51f5f63577b2e7a4792efd6296429dd217718158&amp;device=unknown_device&amp;docs_host=https%3A%2F%2Fdocs.github.com&amp;enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f616c6578626e6577686f7573652f506172616c6c656c2d496e737469747574696f6e732d616e642d436976696c2d526573697374616e63652f353166356636333537376232653761343739326566643632393634323964643231373731383135382f4e6577686f7573655f446174613146696e616c506f737465722e706466&amp;logged_in=true&amp;nwo=alexbnewhouse%2FParallel-Institutions-and-Civil-Resistance&amp;path=Newhouse_Data1FinalPoster.pdf" type="application/pdf" width="700px" height="700px">
<embed src="https://viewscreen.githubusercontent.com/view/pdf?browser=safari&amp;bypass_fastly=true&amp;color_mode=auto&amp;commit=51f5f63577b2e7a4792efd6296429dd217718158&amp;device=unknown_device&amp;docs_host=https%3A%2F%2Fdocs.github.com&amp;enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f616c6578626e6577686f7573652f506172616c6c656c2d496e737469747574696f6e732d616e642d436976696c2d526573697374616e63652f353166356636333537376232653761343739326566643632393634323964643231373731383135382f4e6577686f7573655f446174613146696e616c506f737465722e706466&amp;logged_in=true&amp;nwo=alexbnewhouse%2FParallel-Institutions-and-Civil-Resistance&amp;path=Newhouse_Data1FinalPoster.pdf">
<p>
This browser does not support PDFs. Please download the PDF to view it:
<a href="https://viewscreen.githubusercontent.com/view/pdf?browser=safari&bypass_fastly=true&color_mode=auto&commit=51f5f63577b2e7a4792efd6296429dd217718158&device=unknown_device&docs_host=https%3A%2F%2Fdocs.github.com&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f616c6578626e6577686f7573652f506172616c6c656c2d496e737469747574696f6e732d616e642d436976696c2d526573697374616e63652f353166356636333537376232653761343739326566643632393634323964643231373731383135382f4e6577686f7573655f446174613146696e616c506f737465722e706466&logged_in=true&nwo=alexbnewhouse%2FParallel-Institutions-and-Civil-Resistance&path=Newhouse_Data1FinalPoster.pdf">Download
PDF</a>.
</p>
</embed>
</object>
