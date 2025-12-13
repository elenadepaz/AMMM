int nTasks =...;
int nThreads =...;
int nCPUs =...;
int nCores =...;
float rh [1.. nThreads ]=...; // resources requested by each thread
float rc [1.. nCPUs ]=...; // capacity of each computer
int CK [1.. nCPUs ][1.. nCores ]=...; // cores belonging to each computer
int TH [1.. nTasks ][1.. nThreads ]=...; // threads belonging to each task
// Preprocessing to get number of threads per task and cores per computer
int nThreadsPerTask [1.. nTasks ];
int nCoresPerCPU [1.. nCPUs ];
execute {
	for(var i = 1; i <= nTasks ; i ++) {
		nThreadsPerTask [ i ] = 0;
		for ( var t = 1; t <= nThreads ; t ++) {
			nThreadsPerTask [ i ] += TH [ i ][ t ];
		}
	}
	for(var j = 1; j <= nCPUs ; j ++) {
		nCoresPerCPU [ j ] = 0;
		for ( var c = 1; c <= nCores ; c ++) {
			nCoresPerCPU [ j ] += CK [ j ][ c ];
		}
	}
}
// Set CPLEX parameter for 1% optimality gap
execute {
	cplex.epgap = 0.01;
}
// Decision variables
dvar boolean x_tc [1..nTasks][1..nCPUs]; // task t is served from computer c
dvar boolean x_hk [1..nThreads][1..nCores]; // thread h is served from core k
dvar float+ z ; // positive real with percentage of load of the highest loaded computer
// Objective function
maximize z ;
// Constraints
subject to {
	// Constraint 1
	forall(h in 1.. nThreads)
		sum (k in 1.. nCores ) x_hk [h,k] == 1;	

	// Constraint 2
	forall(t in 1.. nTasks , c in 1.. nCPUs)
		sum (h in 1.. nThreads)
		sum (k in 1.. nCores)
		TH[t][h] * CK [c][k] * x_hk [h,k] <= nThreadsPerTask[t] * x_tc[t,c];	

	// Constraint 3
	forall(c in 1.. nCPUs , k in 1.. nCores)
		CK [c][k] * sum (h in 1.. nThreads) rh[h] * x_hk [h,k] <= rc[c];

	// Constraint 4
	z == sum(c in 1..nCPUs) sum(t in 1..nTasks) (1-x_tc[t,c]);

}
