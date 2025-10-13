# Trees that were rerooted for better or worse

## Overall
currently my pipeline reroots to the outgroup instead of the ancestor of the outgroup. change this

## Adeno associated virus 
**i think this virus as a whole needs to be rethought a little?**
This is an umbrella for the 10ish trees for adenovirus. they all seem a little iffy and im trying to figure out why 
### Adeno_associated_virus_1_rerooted_outgroup_optimized.jsonl.gz
This is a weird tree. Half the data has short branches and the other half have many identical nodes on really long branches. the reroot has made the tree look imbalanced but im not sure if this has more to do with the tree itself or a failed root. Some of these viral trees, especially the viruses with many separate trees are confusing me and made need to be discussed. 

10/13: i have established that i added canddiate outgroups correctly and then rerooted the tree incorrectly. the tree still has weird data that makes rerooting look odd but now that its rerooted to the correct sample it causes less concern than before. i still need to understand why half of this data is different than the other half\

10/13: this tree seems like its 2 trees. i kind of wonder if it is 2 different viruses. aa1 and aa2? will try to figure out if this is on purpose. 

10/13: the more i look at the actual data the more im confused how these viruses were split up... asking angie about this 
 

## Aleutian mink disease
10/13: i added a long branch with the outgroup but it didnt reroot correctly. so maybe success ? but the pipeline didnt reroot correctly

10/13: maybe pipeline worked. i may have downloaded incorrectly. will check now 

10:13: download seems fine. pipeline must have messed up reroot. will reroot manually. honestly for the best. i need to fix reroot anyway. it shouldnt reroot to outgroup. it needs to reroot to ancestor between outgroup and tree

10/13: reroot works manually will need to fix reroot rule. outgroup seems ok. there are some were samples on the edge that are either differnt mutation spectra or poor samples. or possibly need to root differntly ? will need to look into those samples for pruning potentially

## Avian leukemia virus 
10/13: outgroup added. not on a super long branch. not sure if this is a good one. may have to check taxids. reroot failed again. will need to fix pipeline
10/13: rerooted but it doesnt look balanced at all. i may have to reject this outgroup. i guess it could be unbalanced though 

# Trees that were not assigned an outgroup



