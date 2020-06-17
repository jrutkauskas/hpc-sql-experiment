# Parallel Computing in Oracle PL/SQL

Oracle PL/SQL has the ability to perform some work in parallel.  Does this mean it could be a good language for parallel computing? **Probably not**, but let's find out anyway.

## Introduction and Motivation

You know how when you're in school and taking a bunch of classes and you've had too much coffee and you're procrastinating on other work and you start to overthink things and try to combine ideas from multiple courses together?  Perhaps that's a bit too specific of a situation...

Regardless, when I was enrolled in an introductory DBMS course and a course on high performance (parallel) computing, that's exactly the situation I found myself in one morning.  I thought 'Wouldn't it be interesting if I could combine these two courses to use a database server for parallel computing... HPC-SQL!'

I knew it was ridiculous and would probably have horrible performance since most of the queries in my database course took forever to run anyway, but a morbid curiosity took over and I just had to see how bad it would be... and if the load of my demands would crush my class's poor old Oracle server.

## The Problem to Compute

I had my choice of a few problems I already knew how to parallelize easily, and since I didn't want to spend too much time writing this code, I wanted to pick an easy one.  I also knew that something that requires a lot of data to be stored in the database would be terribly slow since I knew the simple queries I had to write in my DBMS course still took quite a long time... let alone trying to do it hundreds or even thousands of times.

I settled on the problem of computing Riemann sums, specifically estimating this integral:

![integral of cosine of x from 0 to 10](https://render.githubusercontent.com/render/math?math=%24%5Cint_%7B0%7D%5E10%20cos(x)dx%24)

*Yes, I know this is just ![sin(10)](https://render.githubusercontent.com/render/math?math=sin(10)) but the code is general enough to work on any equation that can be calculated in PL/SQL, this one is  just easier to test*




## The Dreaded Code Itself

## Opening Pandora's Box: How to Run the Code

## Performance Results
