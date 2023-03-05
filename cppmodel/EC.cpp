#include <iostream>
// #define int long long
using namespace std;


int qpow(int x, int y, int mod) {
    int res = 1;
    while(y) {
        if(y&1) res=res*x%mod;
        y >>=1;
        x = x*x%mod;
    }
    return res;
}

int inv(int x, int mod) {
    return qpow(x, mod-2, mod);
}


struct Point {
    int x, y;
    Point(){}
    Point(int x, int y):x(x),y(y){}
};

struct Curve {
    int p,a,b,q,gx,gy;
    Curve(int p,int a,int b,int q,int gx,int gy):p(p),a(a),b(b),q(q),gx(gx),gy(gy){}
};

void doublePoint(Point &res, const Point &p1, const Curve &C) {

    if(p1.x == 0 && p1.y == 0) {
        res.x = 0;
        res.y = 0;
        return;
    }

    int mod = C.p;

    int numer, denom, lambda;

    numer = 3*p1.x*p1.x + C.a;
    denom = 2*p1.y;
    lambda = numer*inv(denom, mod) % mod;

    res.x = (lambda*lambda - 2*p1.x) % mod;
    res.y = (lambda*(p1.x - res.x) - p1.y) % mod;

}



void AddPoint(Point &res, const Point & p1, const Point & p2, const Curve &C) {

    int mod = C.p;

    if(p1.x == 0 && p1.y == 0 && p2.x == 0 && p2.y == 0) {
        res.x = 0;
        res.y = 0;
        return;
    }
    if(p1.x == 0 && p1.y == 0) {
        res.x = p2.x;
        res.y = p2.y;
        return;
    }

    if(p2.x == 0 && p2.y == 0) {
        res.x = p1.x;
        res.y = p1.y;
        return;
    }

    //liang ge point bu neng yi yang!!
    //liang ge point bu neng guan yu x zhou dui chen!!
    if(p1.x == p2.x && (p1.y +p2.y) % mod == 0) {
        res.x = 0;
        res.y = 0;
        return;
    }

    int lambda=0;


    lambda = (p2.y-p1.y) * inv((p2.x-p1.x),mod) % mod;

    res.x = (lambda*lambda - p1.x - p2.x) % mod;
    res.y = (lambda*(p1.x-res.x) - p1.y) % mod;
}


//zhe li ke yi fu er jin zhi you hua!
void MulPoint(Point &res, const Point & p1, const int & times, const Curve &C) {
    if(p1.x == 0 && p1.y == 0) {
        res.x = 0;
        res.y = 0;
        return;
    }
    int mod = C.p;
    int tp = times;
    Point _p1;
    _p1.x = p1.x;
    _p1.y = p1.y;
    res.x = 0;
    res.y = 0;
    while(tp) {
        if(tp&1) AddPoint(res,res,_p1,C);
        tp >>= 1;
        doublePoint(_p1, _p1, C);
    }
}

signed main() {

    Curve C(23,1,1,0,0,0);
    Point P(3,10);
    Point Q(9,7);
    Point res;
    AddPoint(res,P,Q,C);
    cout << res.x << " " << res.y << endl;
    Point ress;
    MulPoint(ress,P,2,C);
    cout << ress.x << " " << ress.y << endl;
    return 0;
}
