#include <blis/blis.h>

#include <assert.h>
#include <math.h>

int main(int argc, char** argv)
{
    double M[5][3] = {{ 0, 1, 2},
                      { 3, 4, 5},
                      { 6, 7, 8},
                      { 9,10,11},
                      {12,13,14}};
    double C[5][5];
    int m = 5, n = 5, k = 3;
    double one = 1.0, zero = 0.0;

    for (int i = 0;i < m;i++)
    for (int j = 0;j < n;j++)
        C[i][j] = NAN;

    bli_dgemm(BLIS_NO_TRANSPOSE, BLIS_TRANSPOSE, m, n, k,
               &one, &M[0][0], 3, 1,
                     &M[0][0], 3, 1,
              &zero, &C[0][0], 5, 1);

    // print matrix C
    for (int i = 0;i < m;i++)
    {
        for (int j = 0;j < n;j++)
        {
            printf("%d     ", C[i][j]);
        }
        printf("\n");
    }

    for (int i = 0;i < m;i++)
    for (int j = 0;j < n;j++)
    {
        double ref = 0;
        for (int p = 0;p < k;p++)
            ref += M[i][p]*M[j][p];
        assert(fabs(ref - C[i][j]) < 1e-14);
    }

    return 0;
}
