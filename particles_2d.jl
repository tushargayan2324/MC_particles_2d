using Distributions
using Plots
using BenchmarkTools

function energy(M) 
    e = 0
    n = size(M)[1]
    for i in 1:n #parallelize this 
        e += sum(M[i].^2)
        for j in i+1:n #parallelize this 
            e += 1/sum((M[i] .- M[j]).^2)
        end
    end
    return e
end


function monte(x,T,T0)
    n = size(x)[1]
    for i = 1:n 
        a = rand(1:n)
        l = sqrt(T/T0)
        dn = x[a] + rand(Uniform(-l, l), 2)
        dE = sum(dn.^2) - sum(x[a].^2)
    
        for j = 1:n 
            if  j!=a  
                dE += 1/sum((dn .- x[j]).^2) - 1/sum((x[a] .- x[j]).^2)
            end
             
        end
        q = min(1,exp(-dE/T))
        m = rand()
            if q>m
                x[a] = dn
            end
    end
    return x
end

function monte_new_threaded(x,T,T0)
    n = size(x)[1]
    for i = 1:n # Cant be parallelized dependent loop
        a = rand(1:n)
        l = sqrt(T/T0)
        dn = x[a] + rand(Uniform(-l, l), 2)
        dE = sum(dn.^2) - sum(x[a].^2)

        temp = zeros(Float64,Threads.nthreads())
        Threads.@threads for j = 1:n 
            if  j!=a  
            #@inbounds  dE += 1/sum((dn .- x[j]).^2) - 1/sum((x[a] .- x[j]).^2)
            temp[Threads.threadid()] += 1/sum((dn .- x[j]).^2) - 1/sum((x[a] .- x[j]).^2)        
            end
    
        end
        dE += sum(temp)
        q = min(1,exp(-dE/T))
        m = rand()
            if q>m
                x[a] = dn
            end
    end
    return x
end


function main()

    N = 10^4 #Temp points

    n = 200 #particles 
    
    T0 = 10
    T1 = LinRange(0.000001,T0,N)
    
    x = [rand(Uniform(-1, 1), 2) for i in 1:n ] #list of all particles
    
    #x[1]
    
    println(energy(x))
    
    for i=1:N
        #println(i)
        x = monte(x,T1[N-i+1],T0)
    end
    
    println(energy(x))
        
end

function main_threaded()

    N = 10^4 #Temp points

    n = 200 #particles 
    
    T0 = 10
    T1 = LinRange(0.000001,T0,N)
    
    x = [rand(Uniform(-1, 1), 2) for i in 1:n ] #list of all particles
    
    #x[1]
    
    println(energy(x))
    
    for i=1:N
        #println(i)
        x = monte_new_threaded(x,T1[N-i+1],T0)
    end
    
    println(energy(x))
        
end

#@btime main()

@time main_threaded()

#z = sum(x[i].^2)
# z = zeros(Float64, n)

# for i =1:n
#     z[i] = sqrt( sum(x[i].^2) )
# end

# histogram(z)


# g1 = [x[i][1] for i=1:size(x)[1]]
# g2 = [x[i][2] for i=1:size(x)[1]]


# scatter(g1,g2)
