#include <mfem.hpp>
#include <iostream>

using namespace std;
using namespace mfem;

int main(int argc, char *argv[])
{
    mfem::DenseMatrix A(2, 2);
    mfem::DenseMatrix B(2, 2);
    mfem::DenseMatrix C(2, 2);

    A(0,0) = 1.0;
    A(0,1) = 2.0;
    A(1,0) = 3.0;
    A(1,1) = 4.0;

    B(0,0) = 5.0;
    B(0,1) = 6.0;
    B(1,0) = 7.0;
    B(1,1) = 8.0;

    // C = A * B
    mfem::Mult(A, B, C);

    std::cout << "A * B =" << std::endl;
    C.Print();
    

    return 0;
}