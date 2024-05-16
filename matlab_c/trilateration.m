classdef trilateration
    properties
        ci;         % circle center i
        cj;         % circle center j
        ck;         % circle center k
        di;         % radius i
        dj;         % radius j
        dk;         % radius k
    end

    methods (Access = public)
        function obj = trilateration(c1, c2, c3)
            obj.ci = c1;
            obj.cj = c2;
            obj.ck = c3;
        end

        function [intij, intjk, intik] = trilatIntersect(obj, d1, d2, d3)
            obj.di = d1;
            obj.dj = d2;
            obj.dk = d3;
            [intij1, intij2] = obj.intersection(obj.ci, obj.cj, obj.di, obj.dj);
            intij = obj.intersectionDetermine(intij1, intij2, obj.ck, obj.dk);
            
            [intjk1, intjk2] = obj.intersection(obj.cj, obj.ck, obj.dj, obj.dk);
            intjk = obj.intersectionDetermine(intjk1, intjk2, obj.ci, obj.di);   

            [intik1, intik2] = obj.intersection(obj.ci, obj.ck, obj.di, obj.dk);
            intik = obj.intersectionDetermine(intik1, intik2, obj.cj, obj.dj);
        end

        function [i, j] = trilatCenter(obj, d1, d2, d3)
            obj.di = d1;
            obj.dj = d2;
            obj.dk = d3;
            [intij, intjk, intik] = obj.trilatIntersect(d1, d2, d3);
            i = (intij(1) + intjk(1) + intik(1))/3;
            j = (intij(2) + intjk(2) + intik(2))/3;
        end
    end

    methods (Access = private)
        function [int1, int2] = intersection(~, c1, c2, d1, d2)
            x12 = c2(1) - c1(1);
            y12 = c2(2) - c1(2);
            d = sqrt(x12^2 + y12^2);

            if d > (d1 + d2) || d < abs(d1 - d2) || (d == 0 && d1 == d2)
                error('Circles do not intersect');
            end

            a = (d1^2 - d2^2 + d^2) / (2 * d);
            h = sqrt(d1^2 - a^2);
            P0 = c1 + a * (c2 - c1) / d;

            int1 = P0 + h * [-(c2(2) - c1(2)), (c2(1) - c1(1))] / d;
            int2 = P0 - h * [-(c2(2) - c1(2)), (c2(1) - c1(1))] / d;
        end

        function int = intersectionDetermine(~, int1, int2, c3, d3)
            l = d3 - sqrt( (int1(1)-c3(1))^2 + (int1(2)-c3(2))^2 );
            r = d3 - sqrt( (int2(1)-c3(1))^2 + (int2(2)-c3(2))^2 );
            if l^2 < r^2
                int = int1;
            else
                int = int2;
            end
        end
    end
       

end