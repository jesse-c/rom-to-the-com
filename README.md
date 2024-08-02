# Plan

What percentage of rom-to-the-com do you want? 99% Rom, 1% Com to 1% Rom, 99% Com.

Choose on the slider, and get a recommendation.

Mobile-first

Data: List of movies for each combination: 99x2=198. rom,com: "1,99", "2,98", .., "98,2", "99,1"

I'll need to find n movies but find m, of 198. Keep going until they're all found. What if there aren't 198? Sort them and shift values slightly. E.g. if there's 2 40,60s, one becomes a neighbouring missing value, within a max possible delta.

I could go by larger increments, like 3%, instead of 1%. We'd want more than 1 per increment too?

Max amount?

# Domains

romtothecom.com
romtothe.com

# Loader

Version 3 of 3

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Heart to Laughing Face Loader</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        .loader {
            font-size: 50px;
            position: relative;
            width: 50px;
            height: 50px;
        }
        .loader span {
            position: absolute;
            top: 0;
            left: 0;
            opacity: 0;
            animation: fadeInOut 2s ease-in-out infinite;
        }
        .loader .heart { animation-delay: 0s; }
        .loader .laugh { animation-delay: -1s; }
        @keyframes fadeInOut {
            0%, 100% { opacity: 0; }
            50% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="loader">
        <span class="heart">❤️</span>
        <span class="laugh">😂</span>
    </div>
</body>
</html>
```

Version 4 of 4

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Black and White Heart to Laughing Face Loader</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        .loader {
            position: relative;
            width: 50px;
            height: 50px;
        }
        .loader svg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            animation: fadeInOut 2s ease-in-out infinite;
        }
        .loader .heart { animation-delay: 0s; }
        .loader .laugh { animation-delay: -1s; }
        @keyframes fadeInOut {
            0%, 100% { opacity: 0; }
            50% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="loader">
        <svg class="heart" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="black"/>
        </svg>
        <svg class="laugh" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="10" stroke="black" stroke-width="2" fill="none"/>
            <path d="M7 14s1.5 2 5 2 5-2 5-2" stroke="black" stroke-width="2" fill="none"/>
            <circle cx="9" cy="9" r="1.5" fill="black"/>
            <circle cx="15" cy="9" r="1.5" fill="black"/>
        </svg>
    </div>
</body>
</html>
```

Version 7 of 7

```<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unicode Symbol Heart to Laughing Face Loader</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
            font-family: Arial, sans-serif;
        }
        .loader {
            position: relative;
            width: 50px;
            height: 50px;
            font-size: 40px;
            line-height: 50px;
            text-align: center;
        }
        .loader span {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            animation: fadeInOut 2s ease-in-out infinite;
        }
        .loader .heart { animation-delay: 0s; }
        .loader .laugh { animation-delay: -1s; }
        @keyframes fadeInOut {
            0%, 100% { opacity: 0; }
            50% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="loader">
        <span class="heart">♥</span>
        <span class="laugh">☺</span>
    </div>
</body>
</html>
```

# Data

https://docs.google.com/spreadsheets/d/1woPv_NN1RBHkeqfXkuGSDrcM6usMy7B5tq3A4I9rV-I/edit?gid=0#gid=0
https://www.imdb.com/list/ls058479560/?ref_=exp_t_2
https://www.imdb.com/list/ls000043052/
https://www.imdb.com/list/ls059288416/?ref_=exp_t_1
https://www.imdb.com/list/ls053605210/
https://www.imdb.com/list/ls068778178/?ref_=exp_t_1
https://www.imdb.com/list/ls095161133/


xsv for data extraction from CSVs

De-dupe
xsv frequency -s Title films.csv

Add years

# Ranking

Prompt

For each of these romantic comedy films, determine, out of 100%, how much of them are romance and how much are comedy. For example, a film may be 60% romance and 40% comedy.

Return your determined value as a third column in the CSV text. A value should be in the format of "60,40", for the 2 percentages. Make sure they're surrounded by quotes, so it's a valid CSV file. Try and spread out your assessments so that there's a wide variation.

Validated CSV

"To All the Boys I've Loved Before,2018","80,20"
"To All the Boys I've Loved Before",2018,"80,20"

```
The Bachelor                                    1999  70,30
Cocktail                                        1988  40,60
Secret Admirer                                  1985  65,35
Our Family Wedding                              2010  50,50
Sex and the City 2                              2010  60,40
Forgetting Sarah Marshall                       2008  35,65
License to Wed                                  2007  30,70
Blind Date                                      1987  45,55
40 Days and 40 Nights                           2002  55,45
The Back-up Plan                                2010  60,40
The Heartbreak Kid                              2007  40,60
Picture Perfect                                 1997  65,35
Did You Hear About the Morgans?                 2009  35,65
The Prince and Me                               2004  75,25
Two Can Play That Game                          2001  50,50
Love Don't Cost a Thing                         2003  70,30
A Lot Like Love                                 2005  65,35
Boys and Girls                                  2000  55,45
Just Wright                                     2010  75,25
My Best Friend's Girl                           2008  40,60
Waitress                                        2007  60,40
Laws of Attraction                              2004  50,50
Drive Me Crazy                                  1999  45,55
Win a Date with Tad Hamilton!                   2004  60,40
Serving Sara                                    2002  35,65
That Old Feeling                                1997  55,45
The Perfect Man                                 2005  70,30
A Guy Thing                                     2003  30,70
Life or Something Like It                       2002  40,60
The Pick-up Artist                              1987  45,55
Chasing Liberty                                 2004  65,35
The Last Kiss                                   2006  80,20
Get Over It                                     2001  50,50
Something New                                   2006  75,25
First Daughter                                  2004  60,40
Never Again                                     2001  70,30
The Romantics                                   2010  85,15
What Women Want                                 2011  55,45
All Over the Guy                                2001  45,55
Crush                                           2001  65,35
Head Over Heels                                 2001  55,45
Whatever It Takes                               2000  40,60
My Life in Ruins                                2009  70,30
Boat Trip                                       2002  30,70
On the Line                                     2001  65,35
```

Validate ranks sum to 100%

# Website

## Features

App feedback:
- Good/Bad
- More rom
- More com
- Less rom
- Less com
- Suggest rom,com for a movie, e.g. "this should be 80,20"
- Add a new film, with ranking
- Suggest removal, for not being a romcom

Analytics:
- Track changes
- Automate re-ranking

## Approach

- Static:
  - Fast
  - Simple

- Dynamic:
  - Storage?
  - Still can be fast
    - Easier/quicker for features
  - Auth? Spam, abuse, ...
    - Unless people create an account with a verified email, there's no choice?
    - Protection:
      - Rate limiting
      - Captcha
      - Max actions:
        - On 1 film
        - On more/less rom/com
        - On new film
        - .. On any individual action (event)
      - ...

- How would a feature work in dynamic?
  - Button for "More rom", which does something in the backend
    - Needs to give feedback in the UI that the action completed. Async?
    - Need to explain that it's batched. At first only? Or just have it live since the data is so small? But with the risk, I want to moderate each action. I can just collect the events then, run locally, and update the latest.

Data domain:

- Title,Year,Rank
- Unique ID: For app component. Consistent per film
  - Generate once

Event (action) sourcing?

v1 → v2?
