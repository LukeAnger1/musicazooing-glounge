#!/usr/bin/env python3

import redis

r = redis.Redis()

def play_counts():
    global r

    members = [x.decode() for x in r.smembers("musicacommonset")]
    plays_strs = r.mget(*["musicacommon.%s" % member for member in members])
    titles = r.mget(*["musicatitle.%s" % member for member in members])

    plays = [int(x) for x in plays_strs]
    titles = [x.decode() if x else "%s (loading)" % member for member, x in zip(members, titles)]
    return list(zip(members, titles, plays))

if __name__ == '__main__':
    freqs = play_counts()
    freqs.sort(key=lambda e: e[2], reverse=True)
    for a, b, c in freqs:
        print(c,a,b)
