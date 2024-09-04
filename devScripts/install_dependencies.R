isradDesc<-desc::desc("../Rpkg/DESCRIPTION")
dependencies<-isradDesc$get_deps()
imports<-dependencies[dependencies$type=="Imports",2]
#print(imports)
install.packages(pkgs=imports, repos="https://cloud.r-project.org")

