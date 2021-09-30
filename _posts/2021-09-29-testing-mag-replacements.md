---
title: Testing Replacements for Microsoft Academic
author: Michael Weishuhn
date: 2021-09-29 18:32:00 -0000
categories: [MAG, The Lens, Semantic Scholar]
tags: [data]
---

As we've all heard, [Microsoft Academic is shutting down](https://www.microsoft.com/en-us/research/project/academic/articles/microsoft-academic-to-expand-horizons-with-community-driven-approach/). While many people have not heard of them, they were by far the largest source of scholarly metadata. This data powered, directly or indirectly, many of the sites academics use today. There have been a number of blog posts covering "what's next" ([1](https://www.natureindex.com/news-blog/microsoft-academic-graph-discontinued-whats-next), [2](https://blogs.lse.ac.uk/impactofsocialsciences/2021/05/27/goodbye-microsoft-academic-hello-open-research-infrastructure/)). None of them get into the details of where tools builders should turn to after MAG. So this is a post attempting to do that with the two major players currently out there. [The Lens](https://www.semanticscholar.org/) and [Sematic Scholar](https://www.semanticscholar.org/). The bulk of the test is done by randomly selecting 100,000 papers from the MAG corpus, querying each of the services, and comparing the results.

# Deciding who to test

I know there are others out there like CrossRef, Dimensions, CORE, etc but for my purposes I want:

1. The most data possible, this means I am looking at a data aggregator who will blend in data from sources like CrossRef.
2. It needs to be free. Inciteful is free and I can only keep it that way if my data is free. (Dimensions is paid)
3. I need either bulk data dumps or insanely high API limits (so I can download each paper individually). (CORE has low API limits)
4. It needs to be kept up to date. Data dumps don't help if they are a year old. (CORE's data dumps are old)

Given the above criteria, as of now, The Lens and Semantic Scholar are the only ones which fit the bill. If you know if any others that might work, let me know.

There have been rumblings about [OpenAlex](https://blog.ourresearch.org/openalex-update-june/) but unfortunately as of this writing it is not yet live.

# Evaluation Criteria

For the two that made it into the ring. I'm going to be evaluating them on a few different criteria:

1. Overall Coverage
2. The Data Structure (how are the authors, institutions, etc structured?)
3. Data Freshness (time from a paper being published to it being integrated)
4. Updated Data Accessibility
5. Data Enrichments (citation contexts, external ids, etc)
6. Other API features (search endpoints, etc)

These criteria are just what's important for Inciteful, YMMV.

# Overall Coverage

Let's start by discussing what "coverage" actually means. Coverage in this context can mean a few different things:

1. The most items in the index
2. The most "academic" papers in the index
3. The most citations in the index
4. et al

For my purposes, I'm most interested in a combination of 2 and 3. I don't care if the index has a ton of stuff that is not academic in nature and given the service Inciteful provides, I want to have the papers which are in the index to have the best citation coverage possible.

## The Test

The main part of the test is going to be evaluating the coverage portion. Being data aggregators each of them get their data from a different set of sources and integrate them into a coherent database in their own way. As of now I am testing this by randomly selecting 100,000 MAG ids out of the latest data dump (2021-08-30), pulling the data from Mag, The Lens, and Semantic Scholar using their respective APIs. From there I am comparing the results from each service. Focusing specifically on if the paper was found, and if so, the citation and reference counts. Since Inciteful is most concerned about making connections between papers, that is what I will be focusing on and making conclusions about. You may read the results differently.

## Results

Combining:
https://academic.microsoft.com/paper/3020022875/
https://academic.microsoft.com/paper/3035702361/
