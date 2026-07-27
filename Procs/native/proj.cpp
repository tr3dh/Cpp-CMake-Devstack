#include <mfem.hpp>
#include <iostream>

using namespace std;
using namespace mfem;

int main(int argc, char *argv[])
{
    MPI_Session mpi(argc, argv);

    int rank = mpi.WorldRank();
    int size = mpi.WorldSize();

    //
    int local_value = rank + 1;

    int sum = 0;

    //
    MPI_Reduce(
        &local_value,
        &sum,
        1,
        MPI_INT,
        MPI_SUM,
        0,
        MPI_COMM_WORLD
    );

    //
    if (rank == 0)
    {
        cout << "Gesamtsumme: " << sum << endl;
    }

    return 0;
}