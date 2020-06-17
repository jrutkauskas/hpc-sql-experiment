# Parallel Computing in Oracle PL/SQL

Oracle PL/SQL has the ability to perform some work in parallel.  Does this mean it could be a good language for parallel computing? **Probably not**, but let's find out anyway.

## Introduction and Motivation

You know how when you're in school and taking a bunch of classes and you've had too much coffee and you're procrastinating on other work and you start to overthink things and try to combine ideas from multiple courses together?  Perhaps that's a bit too specific of a situation...

Regardless, when I was enrolled in an introductory DBMS course and a course on high performance (parallel) computing, that's exactly the situation I found myself in one morning.  I thought 'Wouldn't it be interesting if I could combine these two courses to use a database server for parallel computing... HPC-SQL!'

I knew it was ridiculous and would probably have horrible performance since most of the queries in my database course took forever to run anyway, but a morbid curiosity took over and I just had to see how bad it would be... and if the load of my demands would crush my class's poor old Oracle server.

## The Problem to Compute

I had my choice of a few problems I already knew how to parallelize easily, and since I didn't want to spend too much time writing this code, I wanted to pick an easy one.  I also knew that something that requires a lot of data to be stored in the database would be terribly slow since I knew the simple queries I had to write in my DBMS course still took quite a long time... let alone trying to do it hundreds or even thousands of times.

I settled on the problem of computing Riemann sums, which will be abbreviated in the code as the RECT problem (because it calculates rectangular areas). Specifically, the code estimates this integral with 8,388,600 individual rectangles:

![integral of cosine of x from 0 to 10](https://render.githubusercontent.com/render/math?math=%24%5Cint_%7B0%7D%5E10%20cos(x)dx%24)

*Yes, I know this is just ![sin(10)](https://render.githubusercontent.com/render/math?math=sin(10)) but the code is general enough to work on any equation that can be calculated in PL/SQL, this one is  just easier to test*





## Algorithm
My strategy for computation is basically splitting up the range of the integral into equal-sized chunks, one for each 'thread' I would be creating.  

Each thread calculates its portion of the area under the curve, then stores the result.

After all threads complete, the partial results are summed up to calculate the correct result


## The Dreaded Code Itself

The code is quite compact, using only a few procedures, tables, and one trigger.  It's not as clean as it could be, but if I touch this code any more, the exposure could become toxic so I'm sharing it as-is.

### Tables

There are 3 tables I use

1. `rect_params` - Contains the parameters that will be used to determine how to run the program in parallel, specifically, it details:

    - The number of threads to create

    - The start and end limits of the integral

    - The number of steps / rectangles to use in estimating the area

2. `rect_partial_values` - As each thread finishes calculating its portion of the area, it stores it in this table, along with the timestamp of when it completed its calculation

    - When the algorithm is first started, the timestamp of the start is also inserted into this table, thus allowing for easy calulation of the total computation time: MAX(timestamp) - MIN(timestamp)

3. `rect_results`

### Procedures

#### The Trigger



## Opening Pandora's Box: How to Run the Code

## Performance Results

## Future Work

None! I don't ever want to touch this again and I don't think anyone should either.

## Conculsion
