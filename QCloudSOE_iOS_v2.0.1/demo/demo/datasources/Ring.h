#ifndef __RING_H__
#define __RING_H__

#include <vector>
#include <cassert>

struct Ring {
    struct Info {
        char* data;
        int len;
    };

    std::vector<char> cache;
    int start = 0;
    int end = 0;
    int remain_len = 0;
    Ring(int size = 0) {
        assert(size < 100000000);
        remain_len = size + 1;
        cache.resize(remain_len);
    }
    int size() {
        if (end >= start) {
            return end - start;
        } else {
            return end + remain_len - start;
        }
    }

    void push(char* data, int len) {
        if (len > remain_len - 1) {
            data = data + len - remain_len + 1;
            len = remain_len - 1;
        }
        int remain = remain_len - 1 - size();
        if (remain < len) {
            pop(len - remain);
        }
        if (end >= start) {
            if (remain_len - end > len) {
                memcpy(&cache[end], data, len);
                end = end + len;
            } else {
                int l1 = remain_len - end;
                memcpy(&cache[end], data, l1);
                int l2 = len - l1;
                memcpy(&cache[0], data + l1, l2);
                end = l2;
            }
        } else {
            memcpy(&cache[end], data, len);
            end = end + len;
        }
    }

    std::vector<Info> data() {
        if (end < start) {
            return {Info{.data = &cache[start], .len = remain_len - start},
                    Info{.data = &cache[0], .len = end}};
        } else {
            return {Info{.data = &cache[start], .len = size()}};
        }
    }

    void pop(int len) {
        if (len >= size()) {
            start = end;
        } else {
            start = (start + len) % remain_len;
        }
    }

    void clear() { start = end; }

    size_t capacity() { return cache.size() - 1; }
    
};

#endif
