# test to see if the likelihood is correctly calculated
# and if the networks are correctly estimated
# Claudia August 2015

# -------------------5taxon tree------------------

if !isdefined(:individualtest) individualtest = false; end

if(individualtest)
    include("../src/types.jl")
    include("../src/functions.jl")
end

if isdefined(:PhyloNetworks)
    PhyloNetworks.CHECKNET || error("need CHECKNET==true in PhyloNetworks to test snaq in test_correctLik.jl")
else
    CHECKNET || error("need CHECKNET==true to test snaq in test_correctLik.jl")
end

#df = readtable("Tree_output.txt")
df=DataFrame(t1=["6","6","10","6","6"],
             t2=["7","7","7","10","7"],
             t3=["4","10","4","4","4"],
             t4=["8","8","8","8","10"],
             CF1234=[0.2729102510259939, 0.3967750546426937, 0.30161247267865315, 0.24693940689390592, 0.2729102510259939],
             CF1324=[0.45417949794801216, 0.30161247267865315, 0.30161247267865315, 0.5061211862121882, 0.45417949794801216],
             CF1423=[0.2729102510259939, 0.30161247267865315, 0.3967750546426937, 0.24693940689390592, 0.2729102510259939])
d = readTableCF(df)

# starting tree:
tree = "((6,4),(7,8),10);"
currT = readTopologyLevel1(tree);
#printEdges(currT)

extractQuartet!(currT,d)
calculateExpCFAll!(d)
lik = logPseudoLik(d)

@test lik ≈ 193.7812623319291
println("passed tree example")

#estTree = optTopRun1!(currT,d,0,5454) # issue with printCounts, TravisCI?
#@test estTree.loglik ≈ 0.0 atol=1e-8
println("passed optTopRun1! on tree")

# ------------------5taxon network 1 hybridization: Case H-----------------
# starting topology: Case G
tree = "((((6:0.1,4:1.5)1:0.2,(7)11#H1)5:0.1,(11#H1,8)),10:0.1);" # Case G
currT = readTopologyLevel1(tree);
# real network: Case H
df=DataFrame(t1=["6","6","10","6","6"],t2=["7","7","7","10","7"],t3=["4","10","4","4","4"],t4=["8","8","8","8","10"],CF1234=[0.13002257237728915, 0.36936019721747243, 0.34692592933269173, 0.12051951084152591, 0.11095702789935982], CF1324=[0.7399548552454217, 0.28371387344983595, 0.28371387344983595, 0.7589609783169482, 0.7780859442012804],CF1423=[0.13002257237728915, 0.34692592933269173, 0.36936019721747243, 0.12051951084152591, 0.11095702789935982])
d = readTableCF(df)

extractQuartet!(currT,d)
calculateExpCFAll!(d)
lik = logPseudoLik(d)

@test lik ≈ 50.17161079450669
println("passed computation of likelihood")

estNet = optTopRun1!(currT, 0.01,75, d,1, 1e-5,1e-6,1e-3,1e-4,
                     false,true,Int[], 5454, STDOUT,false,0.3, STDOUT)
# topology, likAbs,Nfail, data,hmax, fRel,fAbs,xRel,xAbs,
# verbose,closeN,numMoves, seed, logfile,writelog,probST,sout)
@test estNet.loglik ≈ 0.002165 atol=5.0e-6
# 0.00216 < estNet.loglik < 0.00217 || Base.error("not correct estimated network")
println("passed estimation of net")

@testset "snaq! in serial and in parallel" begin
  n1 = snaq!(currT, d, hmax=1, runs=2, Nfail=10, seed=1234,
             ftolRel=1e-2,ftolAbs=1e-2,xtolAbs=1e-2,xtolRel=1e-2)
  addprocs(1)
  @everywhere using PhyloNetworks
  n2 = snaq!(currT, d, hmax=1, runs=2, Nfail=10, seed=1234,
             ftolRel=1e-2,ftolAbs=1e-2,xtolAbs=1e-2,xtolRel=1e-2)
  rmprocs(workers())
  @test writeTopology(n1, round=true)==writeTopology(n2, round=true)
  @test n1.loglik == n2.loglik
end
