---
title: Testing Replacements for Microsoft Academic Graph
author: Michael Weishuhn
date: 2021-10-08 14:32:00 -0000
categories: [data]
tags: [data, MAG, The Lens, Semantic Scholar]
---

As we've all heard, [Microsoft Academic is shutting down](https://www.microsoft.com/en-us/research/project/academic/articles/microsoft-academic-to-expand-horizons-with-community-driven-approach/). While many people have not heard of them, they were by far the largest source of scholarly metadata. This data powered, directly or indirectly, many of the sites academics use today. There have been a number of blog posts covering "what's next" ([1](https://www.natureindex.com/news-blog/microsoft-academic-graph-discontinued-whats-next), [2](https://blogs.lse.ac.uk/impactofsocialsciences/2021/05/27/goodbye-microsoft-academic-hello-open-research-infrastructure/)). None of them get into the details of where tools builders should turn to after MAG. So this is a post attempting to do that with the two major players currently out there. [The Lens](https://www.semanticscholar.org/) and [Semantic Scholar](https://www.semanticscholar.org/). The bulk of the test is done by randomly selecting 100,000 papers from the MAG corpus, querying each of the services, and comparing the results.

# Deciding Who to Test
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
2. [Data Structure](#2-data-structure) (how are the authors, affiliations, etc structured?)
3. [Data Enrichment](#3-data-enrichment) (citation contexts, external ids, etc)
4. [Updated Data Accessibility](#4-updated-data-accessibility)
5. [API features](#5-api-features)
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

The first table is simple summary data cut a few different ways. The first column of data is all of the items we found in Inciteful. It doesn't equal 100k exactly because I did the random number generation from the ID database I maintain. This database contains all of the historical IDs as well as the current ones. Over time MAG drops items from it's DB for various reasons. So in this instance ~3.7% of the IDs in my database were dropped by MAG. The second and third columns filter results to only those papers found by The Lens and Semantic Scholar respectively. The fourth column filters down to papers which have any sort of citation data from any source.  The final is non-patent papers with citation data, as those are the papers I'm most interested in.

|                            | Incite Found | Lens Found | SS Found | Has Cit Data | Has Cit &<br />Non-Pat. |
| -------------------------- | ------------ | ---------- | -------- | ------------ | ----------------------- |
| Total Papers               | 96,331       | 72,102     | 68,451   | 50,929       | 38,674                  |
| lens_found                 | 72,097       | 72,102     | 64,986   | 37,478       | 37,478                  |
| ss_found                   | 66,733       | 64,986     | 68,451   | 37,348       | 37,260                  |
| incite_found               | 96,331       | 72,097     | 66,733   | 50,046       | 37,791                  |
| lens_cits                  | 622,631      | 622,632    | 611,576  | 622,632      | 622,632                 |
| ss_cits                    | 702,773      | 697,185    | 730,927  | 730,927      | 730,347                 |
| incite_cits                | 659,948      | 587,171    | 580,993  | 659,948      | 591,214                 |
| lens_refs                  | 647,975      | 647,977    | 619,992  | 647,977      | 647,977                 |
| ss_refs                    | 784,266      | 775,688    | 802,969  | 802,969      | 802,676                 |
| incite_refs                | 683,193      | 602,020    | 582,488  | 683,193      | 610,618                 |
| lens_not_ss                | 7,114        | 7,116      | 0        | 1,313        | 1,313                   |
| ss_not_lens                | 1,750        | 0          | 3,465    | 1,183        | 1,095                   |
| incite_more_cits_than_lens | 1,821        | 1,821      | 1,782    | 1,821        | 1,821                   |
| lens_more_cits_than_incite | 9,897        | 9,898      | 9,745    | 9,898        | 9,898                   |
| incite_more_refs_than_lens | 1,483        | 1,483      | 1,421    | 1,483        | 1,483                   |
| lens_more_refs_than_incite | 10,892       | 10,893     | 10,528   | 10,893       | 10,893                  |
| incite_more_cits_than_ss   | 4,130        | 4,055      | 4,130    | 4,130        | 4,122                   |
| ss_more_cits_than_incite   | 17,115       | 16,994     | 17,868   | 17,868       | 17,856                  |
| incite_more_refs_than_ss   | 3,658        | 3,609      | 3,658    | 3,658        | 3,642                   |
| ss_more_refs_than_incite   | 14,088       | 13,957     | 14,674   | 14,674       | 14,672                  |
| lens_more_cits_than_ss     | 6,971        | 6,972      | 6,972    | 6,972        | 6,972                   |
| ss_more_cits_than_lens     | 14,795       | 14,795     | 14,795   | 14,795       | 14,795                  |
| lens_more_refs_than_ss     | 7,640        | 7,640      | 7,640    | 7,640        | 7,640                   |
| ss_more_refs_than_lens     | 12,872       | 12,873     | 12,873   | 12,873       | 12,873                  |

## Paper Coverage
On a surface level it's clear that there is a big gap in the number of papers which Inciteful found vs the others. The data is below but, making a long story short, it is because MAG includes patents whereas The Lens and SS do not (The Lens does but from a different API).

|             | All        |             |             | Missing<br />From Lens |            |            | Missing<br />From SS |            |             |
| ----------- | ---------- | ----------- | ----------- | ---------------------- | ---------- | ---------- | -------------------- | ---------- | ----------- |
| docType     | #          | Cits        | Refs        | #                      | Cits       | Refs       | #                    | Cits       | Refs        |
| Blank       | 31,202     | 28,119      | 88,227      | 180                    | 105        | 384        | 5,137                | 2,906      | 4,130       |
| Book        | 1,687      | 22,386      | 3,282       | 2                      | 0          | 0          | 134                  | 286        | 0           |
| BookChapter | 1,436      | 1,728       | 6,871       | 6                      | 0          | 35         | 83                   | 35         | 67          |
| Conference  | 1,891      | 21,872      | 20,933      | 7                      | 69         | 83         | 101                  | 61         | 910         |
| Dataset     | 39         | 5           | 0           | 0                      | 0          | 0          | 18                   | 1          | 0           |
| Journal     | 32,453     | 510,423     | 460,603     | 224                    | 2,699      | 4,825      | 1,257                | 5,483      | 19,033      |
| Patent      | 23,679     | 68,734      | 72,575      | 23,679                 | 68,734     | 72,575     | 22,181               | 68,535     | 72,237      |
| Repository  | 1,776      | 5,747       | 18,708      | 122                    | 1,170      | 3,271      | 429                  | 1,630      | 3,792       |
| Thesis      | 2,168      | 934         | 11,994      | 14                     | 0          | 0          | 258                  | 18         | 536         |
| **Total**   | **96,331** | **659,948** | **683,193** | **24,234**             | **72,777** | **81,173** | **29,598**           | **78,955** | **100,705** |

Speculating, by looking at the numbers, it seems as though the Lens tries to keep their data as close as possible to the MAG and maybe does not get involved with disambiguation, etc.  Looking at the second column of the summary table seems to support this, any paper which was found by The Lens was also found by Inciteful (with a few exceptions).  Analyzing when the non-patent papers missing from the Lens were created:

| YEAR | #   |
| ---- | --- |
| NULL | 2   |
| 2016 | 146 |
| 2017 | 18  |
| 2018 | 12  |
| 2019 | 26  |
| 2020 | 97  |
| 2021 | 254 |

A large portion of these are recent, so we can possibly chalk those up to a timing issue where The Lens has not yet updated their database.   The rest are a rounding error for our purposes.

Semantic Scholar on the other hand has a **lot** more missing ~7,000 papers when not accounting for patents.  When I inquired about this, the response I got was that they have filtering when importing data which tries to look for "non-scientific" or gray literature and stops it from entering the index.  So basically they have stricter criteria than MAG for what constitutes academic literature.  Which makes sense and is actually a good thing because once MAG goes away, they are going to already have an opinion as to what to index when they encounter something new.  In a related note, Semantic Scholar is also doing other things like paper disambiguation which made tracking everything down a bit more complicated.  For example with this paper from arXiv MAG indexes both the [actual article](https://academic.microsoft.com/paper/3020022875/) as well as the [conference proceeding](https://academic.microsoft.com/paper/3035702361/).  So it's possible they are also doing other disambiguation which I missed.  In line with them maintaining their own index rather than mirroring it (like Inciteful), it looks as though they have "found" a ~1,700 papers that Inciteful did not as a result of the papers being dropped from MAG. 

## Citation Coverage
I'm most interested in the last column of the summary table (replicated in part below). I want to look at papers which have some sort of citation data associated with them. Papers which don't have any citations or references are pretty useless to Inciteful as I cannot build a graph without them. Ideally the more citations the better.  Also, while patent data is nice to have, it [doesn't seem terribly important](https://twitter.com/Inciteful_xyz/status/1438811333265330183) to my users.

|              | Has Cit & Non-Pat. |
| ------------ | ------------------ |
| Total Papers | 38,674             |
| lens_found   | 37,478             |
| ss_found     | 37,260             |
| incite_found | 37,791             |
| lens_cits    | 622,632            |
| ss_cits      | 730,347            |
| incite_cits  | 591,214            |
| lens_refs    | 647,977            |
| ss_refs      | 802,676            |
| incite_refs  | 610,618            |

The first thing that jumps out is the fact that, across the board, Semantic Scholar has 17% more citations and 23% more references than The Lens, which in turn has more than Inciteful.  This second point is particularly interesting because that means that The Lens is not just mirroring the citation data that it gets from MAG like it seems to be doing for paper data.  It's actually enriching it from other sources.  Semantic Scholar is clearly doing the same thing. 

Digging into the actual comparison between The Lens and Semantic Scholar:

|                        | Has Cit & Non-Pat. |
| ---------------------- | ------------------ |
| lens_more_cits_than_ss | 6,972              |
| ss_more_cits_than_lens | 14,795             |
| lens_more_refs_than_ss | 7,640              |
| ss_more_refs_than_lens | 12,873             |

There are some instances where The Lens outperforms Semantic Scholar, but almost twice as often, it's Semantic Scholar that has more citation data than The Lens. 
# 2. Data Structure
For the data structure piece I am looking into how they are presenting the standard data that is associated with a paper.  That means authors, affiliations, URLs, etc.  I'll try to dive into each here.  In the [next section](#3-data-enrichment) I'll cover data enrichments  

## Paper Data
To start off I'll focus on the paper specific data and present it in table form for easier consumption.

|                                   | The Lens                          | Semantic Scholar                |
| --------------------------------- | --------------------------------- | ------------------------------- |
| Open Access                       | Yes, including license and color  | Only Yes/No                     |
| URLs                              | Yes, multiple URLs per paper      | **Only to Semantic Scholar**    |
| Abstract                          | Yes                               | Yes                             |
| Source                            | Yes, including page numbers, etc  | Only name of journal/conference |
| Publication Type                  | Yes                               | No                              |
| External Ids (PubMed, arXiv, etc) | Yes                               | Yes                             |
| Other Info                        | Page numbers, volumes, and issues | No                              |
| Date                              | Date published and date inserted  | Year Published                  |

Clearly The Lens offers more basic data in their response than Semantic Scholar does.  It's enough to construct a citation if that's the type of service you are looking to build.  Semantic Scholar, on the other hand, is relatively spartan in comparison.  

A big call out I want to make here is that through Semantic Scholar's API, the only URL you get to a paper is the one to Semantic Scholar's site.  While I understand why they are doing it, to drive more eyeballs to their site from sites that use their data, it does add friction between either Semantic Scholar and the site/tool builder or between the site and the user.  There are easy ways around this for papers with external IDS like a DOI, PubMedID or arXiv ID.  

 Here are the links to the data structures for those that are interested in digging deeper. 

- [Semantic Scholar](https://api.semanticscholar.org/graph/v1)
- [The Lens](https://docs.api.lens.org/response-scholar.html)

## Author Data

For Author data on the other hand, Semantic Scholar seems to offer a bit more. 

|                                                                                             | The Lens                 | Semantic Scholar                                                                                                                              |
| ------------------------------------------------------------------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Name                                                                                        | Separate first/last name | Full name and aliases                                                                                                                         |
| [Affiliation Data](https://www.digital-science.com/press-release/grid-passes-torch-to-ror/) | Yes, including grid/ror  | Yes, including grid/ror                                                                                                                       |
| Structured IDs                                                                              | Yes, the author's MAG ID | Yes, using [own disambiguation](https://medium.com/ai2-blog/s2and-an-improved-author-disambiguation-system-for-semantic-scholar-d09380da30e6) |
| URL                                                                                         | No                       | Semantic Scholar URL and author's homepage                                                                                                    |

## Other Data
In terms of "other data", The Lens offers a bunch of other information like publisher information, ISSNs, and [MeSH](https://en.wikipedia.org/wiki/Medical_Subject_Headings) terms that Semantic Scholar does not. 

# 3. Data Enrichment
To me a "data enrichment" is something that the service calculates and serves up as part of their API.  For me, this needs to be above and beyond what MAG provides.  

The Lens enriches their data by pulling in structured data from other sources.  Where possible the identify and present:

- Funding sources
- Clinical trials
- Chemicals
- Patent citations
- Author's ORCID IDs
- Abstracts

Semantic Scholar's data enrichment focuses more on text mining and NLP.  
- Identify "[influential citations](https://www.semanticscholar.org/paper/Identifying-Meaningful-Citations-Valenzuela-Ha/1c7be3fc28296a97607d426f9168ad4836407e4b)"
- Developed [author disambiguation](https://medium.com/ai2-blog/s2and-an-improved-author-disambiguation-system-for-semantic-scholar-d09380da30e6)
- Citation contexts (the text surrounding the citation in a paper)
- [Citation intents](https://medium.com/ai2-blog/citation-intent-classification-bd2bd47559de)
- [Specter Embeddings](https://www.semanticscholar.org/paper/SPECTER%3A-Document-level-Representation-Learning-Cohan-Feldman/a3e4ceb42cbcd2c807d53aff90a8cb1f5ee3f031) - A vector representation of the document
- Author's ORCID IDs
- Abstracts

The types of enrichments available vary pretty widely between the two so, depending on your use case, one may work better for you. 
# 4. Updated Data Accessibility
This one is a pretty specific use case but it's something that most people ingesting the data on a regular basis will need to think about.  How do I ensure I have the most up to date data?  For Inciteful I need to pre-process the data and ingest it into my custom data store, this means I can't really use the API for the bulk of my requirements.
## Data Dumps
To start, both do regular data dumps.  Semantic Scholar has [monthly downloads](https://api.semanticscholar.org/corpus/download/) available to everyone.  I was told that The Lens will do data dumps but you have to request special access.  

I don't have access to a Lens data dump so I can't comment on it.  But the downside to using the Semantic Scholar data dump is that (as of this writing) none of the above enrichments, outside of the abstract, are actually in the data dump.  You need to hit the API to get them.  Which is a problem, since I could really beef up the functionality of the site with them but I need them locally.  I'm not sure how they would feel about me hitting the API a couple of hundred of million times to get the data :) 

## Update Data Through the API
Once you have downloaded a data dump, it would be nice to just be able to hit the API for the most recently changed data rather than download the entire dump once again.  This is how the Crossref API works by default.  The Lens allows you to do that in a round about way through their search API (more on that below) but Semantic Scholar does not.  You can only search papers by keyword or by ID.  That makes it hard to find out about the new papers you've never seen before.  
# 5. API Features
Each service has taken a different approach to building their API.  You can see each of their API home pages here:

- [The Lens](https://docs.api.lens.org/getting-started.html)
- [Semantic Scholar](https://www.semanticscholar.org/product/api)

Both The Lens and Semantic Scholar have API endpoints where you can query a specific paper:

- The Lens: https://api.lens.org/scholarly/{lens_id}
- Semantic Scholar: https://api.semanticscholar.org/graph/v1/paper/{paper_id}

From here this is where they really diverge.  

## The Lens
To start you have to apply for an API key, I ended up getting one with a monthly API limit of 10,000 requests.  That's fine for Inciteful because the full text search is a side feature that very few people actually use on the site.  With your API key you have access to their search endpoint.

Their search endpoint is basically an exposed Elastic Search Cluster that contains their entire corpus.  You can see the documentation [here](https://docs.api.lens.org/request-scholar.html).  But in the end there are a few outcomes from this:  

- You can query the hell out of it in pretty much any way you want
- It's not as fast as a purpose-built endpoint
- It's complicated to get what you want out of it

For example, you can do a full text search across the entire corpus relatively quickly, but the results  multi-word queries are pretty bad because, by default, elastic search does an `OR` boolean search on the multiple words.  It also does not give extra weight to those items which contain both words let alone items that contain both words next to each other.  In addition to the above problems, it will also do a full text search across every field.  This includes field of study, journal title, author names, etc.  So be sure to specify which fields you want to search. 

The query I ended up with when using the full text search on Inciteful was: 

```json
{
    "size": "{{size}}",
    "query": {
        "bool": {
            "must": [
                {
                    "query_string": {
                        "fields": [
                            "title"
                        ],
                        "query": "{{lensSearch}}",
                        "default_operator": "OR"
                    }
                }
            ],
            "should": [
                {
                    "query_string": {
                        "fields": [
                            "title^10",
                            "abstract"
                        ],
                        "query": "{{lensSearch}}",
                        "default_operator": "AND"
                    }
                },
                {
                    "query_string": {
                        "fields": [
                            "title^100",
                            "abstract^5"
                        ],
                        "query": "{{lensSearch}}",
                        "type": "phrase",
                        "phrase_slop": 100
                    }
                }
            ]
        }
    },
    "include": [
        "lens_id",
        "title",
        "abstract",
        "external_ids"
    ]
}
```
I'm not an Elastic Search guru, I know I can improve the query, I just don't know how. So just remember:

"With great power comes great complexity" - (I'm sure someone said that sometime)

## Semantic Scholar
You can play around with the Semantic Scholar endpoint without a key, you'll just be subject to a low rate limit.  When I applied for my key my rate limit was something like 100 requests/second. Woo hoo! 

Semantic Scholar offers a few additional options outside of just the paper endpoint:

- A keyword search
- An author endpoint (more information about an author)
- An author's papers endpoint (all of the papers written by an author)
- A paper's citations and references endpoints (get information about all the papers citing or cited by the paper in question)

There is a bit of complexity in understanding what data you can get from which endpoint.  For example, you can only get a subset of the information about a paper from the keyword search endpoint that you can get from the actual single paper endpoint.  But you can only get a subset of the information about the citations or references from the single paper endpoint, for more info like `intents` and `contexts`, you need to hit the paper's citation and reference endpoints individually.  

I'm not going to go through the details of each endpoint, but I will highlight a few things.  

Starting with the keyword search endpoint, it's dead simple: 

  - `https://api.semanticscholar.org/graph/v1/paper/search?query=covid+vaccination`

In addition to that, the results are what you get on their own site, so you know they are good.  

The author endpoint allows you to get information about a specific author and see all the papers from a specific author.  But just like with the keyword search and paper endpoints, you can only see a subset of the information unless you use the "Author's papers" endpoint.  Don't shoot the messenger.

# Conclusion
Congrats if you've made it this far.  If you read everything, I'm sure you've drawn your own conclusions about what is best for your use case.  There are clearly pros and cons with each and there is no perfect answer.  But if I had to read between the lines about who is most likely to pick up the torch and carry it after MAG, I think it will most likely be Semantic Scholar.  While there are a number of downsides to Semantic Scholar (fewer available fields, less powerful API, etc), it seems to me like they have done the leg work to be able to keep running when MAG shuts down.  At each point they have demonstrated that they have their own independent infrastructure which exists separate from MAG.  They have built their own paper disambiguation, author disambiguation, citation context extraction, and citation intent analyzer.  They also don't seem to guard their data as closely as The Lens (higher API limits, public data dumps, etc).  But all that being said, the ecosystem is lucky to have both and I am very grateful for what each adds to it.  None of our tools would be possible without all the hard work they have done along with the others like Crossref, OpenCitations, the I4OC, Unpaywall, ROR, ORCID, etc.

Finally, while it's incredibly sad that MAG is shutting down but they did the world a huge services by proving the value of enriched/open metadata delivered in a consistent manner with high level of service and professionalism.  I have high hopes that the community will pick up where they left off.  It will take some time for the community to reach parity with MAG but the will is there.  I look forward to seeing where the next few years takes us.  