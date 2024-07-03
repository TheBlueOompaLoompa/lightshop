export default class Color {
    private _r = 0;
    private _g = 0;
    private _b = 0;
    private _h = 0;
    private _s = 0;
    private _v = 0;
    private _hex = '#000000';

    private updateHSV() {
        const val = rgbToHsv(this._r, this._g, this._b);
        this._h = val.h;
        this._s = val.s;
        this._v = val.v;
        this.updateToHex();
    }

    private updateRGB() {
        const val = hsvToRgb(this._h, this._s, this._v);
        this._r = val.r;
        this._g = val.g;
        this._b = val.b;
        this.updateToHex();
    }

    private updateFromHex() {
        // Ensure that the hex code is in the correct format
        const hexRegex = /^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;
        if (!hexRegex.test(this._hex)) {
            throw new Error('Invalid HEX color code');
        }
    
        // Remove the '#' if present and expand shorthand to full form
        this._hex = this._hex.replace(/^#/, '');
        if (this._hex.length === 3) {
            this._hex = this._hex.split('').map(char => char + char).join('');
        }
    
        // Parse the hex components
        const hexRed = this._hex.substring(0, 2);
        const hexGreen = this._hex.substring(2, 4);
        const hexBlue = this._hex.substring(4, 6);
    
        // Convert hex to decimal and update RGB values
        this.r = parseInt(hexRed, 16);
        this.g = parseInt(hexGreen, 16);
        this.b = parseInt(hexBlue, 16);
    }

    private updateToHex() {      
        // Convert each component to hexadecimal and concatenate them
        const hexRed = this.r.toString(16).padStart(2, '0');
        const hexGreen = this.g.toString(16).padStart(2, '0');
        const hexBlue = this.b.toString(16).padStart(2, '0');

        // Combine the components to form the HEX color code
        this._hex = `#${hexRed}${hexGreen}${hexBlue}`;
    }

    public static fromRgb(r: number, g: number, b: number): Color {
        const color = new Color();
        color.r = r;
        color.g = g;
        color.b = b;
        return color;
    }

    public static fromHsv(h: number, s: number, v: number): Color {
        const color = new Color();
        color.h = h;
        color.s = s;
        color.v = v;
        return color;
    }

    public static fromHex(hex: string) {
        const color = new Color();
        color.hex = hex;
        return color;
    }

    public static fromRaw(raw: number) {
        const color = new Color();
        color.r = raw >> 24 & 0xff;
        color.g = (raw >> 16) & 0xff;
        color.b = (raw >> 8) & 0xff;
        return color;
    }

    raw() {
        return (this.r << 24) | (this.g << 16) | (this.b << 8);
    }

    get hex() { return this._hex; }
    set hex(val) { this._hex = val; this.updateFromHex(); }

    get r() { return this._r }
    get g() { return this._g }
    get b() { return this._b }
    get h() { return this._r }
    get s() { return this._s }
    get v() { return this._v }

    set r(val: number) {
        this._r = val;
        this.updateHSV();
    }
    set g(val: number) {
        this._g = val;
        this.updateHSV();
    }
    set b(val: number) {
        this._b = val;
        this.updateHSV();
    }
    set h(val: number) {
        this._h = val;
        this.updateRGB();
    }
    set s(val: number) {
        this._s = val;
        this.updateRGB();
    }
    set v(val: number) {
        this._v = val;
        this.updateRGB();
    }

    toString() {
        return this.hex;
    }
}

// RGB to HSV
function rgbToHsv(r: number, g: number, b: number): { h: number, s: number, v: number } {
    r /= 255, g /= 255, b /= 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h, s, v = max;

    const d = max - min;
    s = max === 0 ? 0 : d / max;

    if (max === min) {
        h = 0; // achromatic
    } else {
        switch (max) {
            default: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        h /= 6;
    }

    return { h: h * 360, s: s * 100, v: v * 100 };
}

// HSV to RGB
function hsvToRgb(h: number, s: number, v: number): { r: number, g: number, b: number } {
    h /= 360;
    s /= 100;
    v /= 100;

    let r, g, b;

    const i = Math.floor(h * 6);
    const f = h * 6 - i;
    const p = v * (1 - s);
    const q = v * (1 - f * s);
    const t = v * (1 - (1 - f) * s);

    switch (i % 6) {
        default: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }

    return { r: Math.round(r * 255), g: Math.round(g * 255), b: Math.round(b * 255) };
}
