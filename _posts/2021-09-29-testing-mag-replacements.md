---
title: Testing Replacements for Microsoft Academic Graph
author: Michael Weishuhn
date: 2021-09-29 18:32:00 -0000
categories: [data]
tags: [data, MAG, The Lens, Semantic Scholar]
---

As we've all heard, [Microsoft Academic is shutting down](https://www.microsoft.com/en-us/research/project/academic/articles/microsoft-academic-to-expand-horizons-with-community-driven-approach/). While many people have not heard of them, they were by far the largest source of scholarly metadata. This data powered, directly or indirectly, many of the sites academics use today. There have been a number of blog posts covering "what's next" ([1](https://www.natureindex.com/news-blog/microsoft-academic-graph-discontinued-whats-next), [2](https://blogs.lse.ac.uk/impactofsocialsciences/2021/05/27/goodbye-microsoft-academic-hello-open-research-infrastructure/)). None of them get into the details of where tools builders should turn to after MAG. So this is a post attempting to do that with the two major players currently out there. [The Lens](https://www.semanticscholar.org/) and [Semantic Scholar](https://www.semanticscholar.org/). The bulk of the test is done by randomly selecting 100,000 papers from the MAG corpus, querying each of the services, and comparing the results.

# Deciding who to test
I know there are others out there like CrossRef, Dimensions, CORE, etc but for my purposes I want:

1. The most data possible, this means I am looking at a data aggregator who will blend in data from sources like CrossRef.
2. It needs to be free. Inciteful is free and I can only keep it that way if my data is free. (Dimensions is paid)
3. I need either bulk data dumps or insanely high API limits (so I can download each paper individually). (CORE has low API limits)
4. It needs to be kept up to date. Data dumps don't help if they are a year old. (CORE's data dumps are old)

Given the above criteria, as of now, The Lens and Semantic Scholar are the only ones which fit the bill. If you know if any others that might work, let me know.

There have been rumblings about [OpenAlex](https://blog.ourresearch.org/openalex-update-june/) but unfortunately as of this writing it is not yet live.

# Data Sources

There are a ton of different metadata providers out there. CrossRef, Dimensions, CORE,
OpenCitations, the publishers themselves, etc. Both The Lens and Semantic Scholar pull data from many of these sources. According to The Len's website they get data from the [following sources](https://www.lens.org/):

![](/assets/img/lens-data-sources.png)

It should be noted that The Lens started off as a patent search product that expanded into academic literature, hence places like the USPTO and WIPO. As far as I'm aware, they are also the source of all patent data coming into Microsoft Academic.

According to Semantic Scholar they get their data from the [following sources](https://www.semanticscholar.org/about/publishers):

![](/assets/img/ss-data-sources.png)

It seems like Semantic Scholar integrates more with primary sources of data than The Lens, who is more of an "aggregator of aggregators".

# Evaluation Criteria
For the two that made it into the ring. I'm going to be evaluating them on a few different criteria:

<!-- no toc -->
1. [Overall Coverage](#1-overall-coverage)
2. [Data Structure](#2-data-structure) (how are the authors, institutions, etc structured?)
3. [Data Freshness](#3-data-freshness) (time from a paper being published to it being integrated)
4. [Updated Data Accessibility](#4-updated-data-accessibility)
5. [Data Enrichment](#5-data-enrichment) (citation contexts, external ids, etc)
6. [Other API features](#6-other-api-features)
   (search endpoints, etc)

These criteria are just what's important for Inciteful, YMMV.

# 1. Overall Coverage

Let's start by discussing what "coverage" actually means. Coverage in this context can mean a few different things:

1. The most items in the index
2. The most "academic" papers in the index
3. The most citations in the index
4. et al

For my purposes, I'm most interested in a combination of 2 and 3. I don't care if the index has a ton of stuff that is not academic in nature and given the service Inciteful provides, I want to have the papers which are in the index to have the best citation coverage possible.

## The Test

The main part of the test is going to be evaluating the coverage portion. Being data aggregators each of them get their data from a different set of sources and integrate them into a coherent database in their own way. As of now I am testing this by randomly selecting 100,000 MAG ids out of the latest data dump (2021-08-30), pulling the data from Mag, The Lens, and Semantic Scholar using their respective APIs. From there I am comparing the results from each service. Focusing specifically on if the paper was found, and if so, the citation and reference counts. The data was pulled from the APIs on 2021-09-29. Since Inciteful is most concerned about making connections between papers, that is what I will be focusing on and making conclusions about. You may read the results differently.

There is also a big hole in this test, the academic literature that never made it into MAG. A future test could include randomly pulling data from other sources such as CrossRef but for now since MAG is the [largest database outside of Google Scholar](https://link.springer.com/article/10.1007/s11192-020-03690-4) this was the best I could do for now.

I'm going to drop a bunch of numbers on you so you now so you can draw your own conclusions. I've also posted the sqlite database with the raw numbers so you can do your own queries.

## Summary Data

The first table is simple summary data cut a few different ways. The first column of data is all of the items we found in Inciteful. It doesn't equal 100k exactly because I did the random number generation from the ID database I maintain. This database contains all of the historical IDs as well as the current ones. Over time MAG drops items from it's DB for various reasons. So in this instance ~3.7% of the IDs in my database were dropped by MAG. The second and third are the same as the first except filtering to The Lens and Semantic Scholar respectively. The final column filters down to papers which have any sort of citation data from any source, as those are the papers I'm most interested in.

|                            | Incite Found | Lens Found | SS Found | Has Cit Data |
| -------------------------- | ------------ | ---------- | -------- | ------------ |
| Total                      | 96,331       | 72,102     | 68,451   | 50,929       |
| lens_found                 | 72,097       | 72,102     | 64,986   | 37,478       |
| ss_found                   | 66,733       | 64,986     | 68,451   | 37,348       |
| incite_found               | 96,331       | 72,097     | 66,733   | 50,046       |
| lens_cits                  | 622,631      | 622,632    | 611,576  | 622,632      |
| ss_cits                    | 702,773      | 697,185    | 730,927  | 730,927      |
| incite_cits                | 659,948      | 587,171    | 580,993  | 659,948      |
| lens_refs                  | 647,975      | 647,977    | 619,992  | 647,977      |
| ss_refs                    | 784,266      | 775,688    | 802,969  | 802,969      |
| incite_refs                | 683,193      | 602,020    | 582,488  | 683,193      |
| lens_only                  | 7,114        | 7,116      | 0        | 1,313        |
| ss_only                    | 1,750        | 0          | 3,465    | 1,183        |
| incite_only                | 22,484       | 0          | 0        | 12,268       |
| incite_more_cits_than_lens | 1,821        | 1,821      | 1,782    | 1,821        |
| lens_more_cits_than_incite | 9,897        | 9,898      | 9,745    | 9,898        |
| incite_more_refs_than_lens | 1,483        | 1,483      | 1,421    | 1,483        |
| lens_more_refs_than_incite | 10,892       | 10,893     | 10,528   | 10,893       |
| incite_more_cits_than_ss   | 4,130        | 4,055      | 4,130    | 4,130        |
| ss_more_cits_than_incite   | 17,115       | 16,994     | 17,868   | 17,868       |
| incite_more_refs_than_ss   | 3,658        | 3,609      | 3,658    | 3,658        |
| ss_more_refs_than_incite   | 14,088       | 13,957     | 14,674   | 14,674       |
| lens_more_cits_than_ss     | 6,971        | 6,972      | 6,972    | 6,972        |
| ss_more_cits_than_lens     | 14,795       | 14,795     | 14,795   | 14,795       |
| lens_more_refs_than_ss     | 7,640        | 7,640      | 7,640    | 7,640        |
| ss_more_refs_than_lens     | 12,872       | 12,873     | 12,873   | 12,873       |

On a surface level it's clear that there is a big gap in the number of papers which Inciteful found vs the others. I'll dive more into that [later](#missing-papers) but making a long story short it is because MAG includes patents whereas The Lens and SS do not (The Lens does but from a different API).

## Citation Coverage

I'm most interested in the last column. I want to look at papers which have some sort of citation data associated with them. Papers which don't have any citations or references are pretty useless to Inciteful as I cannot build a graph without them. Ideally the more citations the better.

## Missing Papers

|             | All        |             |             | Lens Missing |            |            | SS Missing |            |             |
| ----------- | ---------- | ----------- | ----------- | ------------ | ---------- | ---------- | ---------- | ---------- | ----------- |
| docType     | #          | Cits        | Refs        | #            | Cits       | Refs       | #          | Cits       | Refs        |
| Blank       | 31,202     | 28,119      | 88,227      | 180          | 105        | 384        | 5,137      | 2,906      | 4,130       |
| Book        | 1,687      | 22,386      | 3,282       | 2            | 0          | 0          | 134        | 286        | 0           |
| BookChapter | 1,436      | 1,728       | 6,871       | 6            | 0          | 35         | 83         | 35         | 67          |
| Conference  | 1,891      | 21,872      | 20,933      | 7            | 69         | 83         | 101        | 61         | 910         |
| Dataset     | 39         | 5           | 0           | 0            | 0          | 0          | 18         | 1          | 0           |
| Journal     | 32,453     | 510,423     | 460,603     | 224          | 2,699      | 4,825      | 1,257      | 5,483      | 19,033      |
| Patent      | 23,679     | 68,734      | 72,575      | 23,679       | 68,734     | 72,575     | 22,181     | 68,535     | 72,237      |
| Repository  | 1,776      | 5,747       | 18,708      | 122          | 1,170      | 3,271      | 429        | 1,630      | 3,792       |
| Thesis      | 2,168      | 934         | 11,994      | 14           | 0          | 0          | 258        | 18         | 536         |
| **Total**   | **96,331** | **659,948** | **683,193** | **24,234**   | **72,777** | **81,173** | **29,598** | **78,955** | **100,705** |

Combining:
https://academic.microsoft.com/paper/3020022875/
https://academic.microsoft.com/paper/3035702361/

# 2. Data Structure

# 3. Data Freshness

# 4. Updated Data Accessibility

# 5. Data Enrichment

# 6. Other API Features

## Search
