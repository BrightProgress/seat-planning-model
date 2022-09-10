include "globals.mzn";

include "utils.mzn";

enum Blocks;
array[Blocks] of int: capacity;
% Sanity condition: capacity is a positive integer
constraint assert (forall (b in Blocks)(capacity[b] > 0), "Error: negative capacity");

enum Groups;
array[Groups] of int: size;
% Sanity condition: size is a positive integer
constraint assert (forall (g in Groups)(size[g] > 0), "Error: negative size");

% assign a subset of each group to a block
array[Groups,Blocks] of var int: assignment;
% Sanity condition: assignment are non-negative, less than size and less than capacity
constraint forall(g in Groups, b in Blocks)(assignment[g,b] >=0 /\ 
                                            assignment[g,b] <= size[g] /\ 
                                            assignment[g,b] <= capacity[b]);


% Every member in all Groups have to be assigned to a Block : the sum of all assignments 
% for a Group has to be equal to the size of the Group
constraint forall(g in Groups)(sum(b in Blocks)(assignment[g,b]) = size[g]);

% There can be empty seats in the block - the sum of all assignments to a Block has to be 
% less-than-or-equal-to the capacity of the Block
constraint forall(b in Blocks)(sum(g in Groups)(assignment[g,b]) <= capacity[b]);

% An assignment should be at least MIN_SIZE engineers together - any smaller and
% it can affect team-dyamics
int : MIN_GROUP_SIZE;
constraint forall(g in Groups, b in Blocks)(assignment[g,b] = 0 \/ 
                                            assignment[g,b] >= MIN_GROUP_SIZE);

% Support definitions
int : num_groups = let {var Groups : g} in dom_size(g);
int : num_blocks = let {var Blocks : b} in dom_size(b);
int : MAX_SPLITS;
int : MAX_BLOCK_ASSIGNMENTS;
int : MAX_DISTANCE;

solve satisfy;

output ["num_groups=\(num_groups)\n",
        "Space=\(show(capacity))\n",
        show2d(assignment)];