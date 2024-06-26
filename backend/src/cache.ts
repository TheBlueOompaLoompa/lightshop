export default class Cache {
    private _cache: CacheStore = {};

    constructor() {}

    async useCache(tag: string, clojrurue: () => {}) {
        if(this._cache[tag]) {
            return this._cache[tag];
        } else {
            const data = await clojrurue();
            this._cache[tag] = data;
            return data;
        }
    }

    groupInvalidate(tagStart: string) {
        Object.keys(this._cache).forEach(tag => {
            if(tag.startsWith(tagStart)) {
                this.invalidate(tag);
            }
        });
    }

    invalidate(tag: string) {
        this._cache[tag] = undefined
    }
}

interface CacheStore {
   [key: string]: any;
}
