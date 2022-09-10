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

% Search space reduction: Too many groups assigned to a Block make it too heterogenous
int : MAX_BLOCK_ASSIGNMENTS;
var int : max_assignments_in_block = max(b in Blocks)(sum(g in Groups)(assignment[g,b] > 0));
constraint  max_assignments_in_block <= MAX_BLOCK_ASSIGNMENTS;

% Search space reduction: at most MAX_SPLITS sub-groups for each Group
int : MAX_SPLITS;
constraint forall(g in Groups)(sum(b in Blocks)(assignment[g,b] > 0) <= MAX_SPLITS);

% Search space reduction: Split Groups should be assigned to adjacent Blocks
int: MAX_DISTANCE;
constraint forall(g in Groups)(distance(g) <= MAX_DISTANCE);


% Metrics for optimization
var int : num_allocations = sum(g in Groups)(num_blocks - count_eq(assignment[g,..], 0));
var int : min_free = min(b in Blocks)(capacity[b] - sum(g in Groups)(assignment[g,b]));
var int : max_free = max(b in Blocks)(capacity[b] - sum(g in Groups)(assignment[g,b]));
var int : disparity_free = max_free - min_free;
var int : max_distance = max(g in Groups)(distance(g));


%% Optimization objectives - (comment this line to check for all optimal solutions)
%solve minimize lex_embedding3(num_allocations, num_groups*num_blocks, max_distance, num_blocks, max_free, 4);

%% Uncomment the following two lines to generate ALL optimal solutions for seat_data_v1.dzn
constraint num_allocations <= 10 /\ max_distance <= 1 /\ max_free <= 2;
solve satisfy;

output ["num_groups=\(num_groups)\n",
        "Space=\(show(capacity))\n", 
        "Allocations=\(num_allocations)\n",
        "Min Free=\(min_free)\n", 
        "Max Free=\(max_free)\n", 
        "Max Distance=\(max_distance)\n",
        show2d(assignment)];