def rot(arr, k):
    k = k % len(arr)
    count = 0
    start = 0
    while count < len(arr):
        current = start
        prev = arr[start]
        while 1:
            current = (current + k) % len(arr)
            prev, arr[current] = arr[current], prev
            count += 1
            if start == current:
                break
        start += 1



a = list(range(10))
rot(a, 3)
print(a)
rot(a, -3)
print(a)
rot(a, -3)
print(a)
