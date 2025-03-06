from collections import defaultdict

def max_card_groups(N, cards):
    count = defaultdict(int)
    for card in cards:
        count[card % 5] += 1
    groupCount = 0
    for key in list(count.keys()):
        comp = 5 - key
        if key == 0 or (comp in count and comp != key) or key == 5:
            groupCount += min(count[key], count[comp])
    return groupCount + (count[0] // 2)


N = int(input())
cards = list(map(int, input().split()))
print(max_card_groups(N, cards))