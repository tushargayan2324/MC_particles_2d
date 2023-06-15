using Distributions
#using Plots
using BenchmarkTools
using GLMakie

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

# function main()

#     N = 10^4 #Temp points

#     n = 200 #particles 
    
#     T0 = 10
#     T1 = LinRange(0.000001,T0,N)
    
#     x = [rand(Uniform(-1, 1), 2) for i in 1:n ] #list of all particles
    
#     #x[1]
    
#     println(energy(x))
    
#     for i=1:N
#         #println(i)
#         x = monte(x,T1[N-i+1],T0)
#     end
    
#     println(energy(x))
        
# end

#@btime main()

#@time main_threaded()


GLMakie.activate!(inline=false)

n = 75

data = Observable([rand(Uniform(-1,1), 2) for i in 1:n])

data[][1:4]

g1 = @lift([$data[i][1] for i=1:n])
g2 = @lift([$data[i][2] for i=1:n])


f, ax, im = scatter(g1,g2) #heatmap(data, colormap = [:black, :white]; axis = (; aspect = 1,xzoomlock=true,yzoomlock=true), )

#deactivate_interaction!(ax, :rectanglezoom,)

#hidedecorations!(ax)
#hidexdecorations!(ax, ticks = false)
#hideydecorations!(ax, ticks = false)


f[2, 1] = buttongrid = GridLayout(tellwidth = false)

button1 = buttongrid[1,1] = Button(f, label="reset")

on(button1.clicks) do click1
    data[] = [rand(Uniform(-1,1), 2) for i in 1:n]
    #data[][1,1] = false
    notify(data)
end

stop_butn = Observable(1)

button2 = buttongrid[1,2] = Button(f, label="stop")

on(button2.clicks) do click2
    stop_butn[] = (stop_butn[] + 1)%2
    print(stop_butn[])
    notify(stop_butn)
end

# button3 = buttongrid[1,3] = Button(f, label="start")

# on(button3.clicks) do click3
#     #something
#     #stop_butn[] = 1
#     #notify(stop_butn)
#     println("true")
#     #while_run()
#     for_run()
#     println("end")
# end

sg = SliderGrid(f[3, 1],
(label = "temprature", range = 0.0001:0.01:2.7, format = "{:.1f}K", startvalue = 2),
)

temperature_ = sg.sliders[1].value



#    stop_butn[]

# while Bool(stop_butn[])==true
#     data[] = monte_new(data[],temp)
#     magn_cal += magnetization(data[])
#     erg_cal += energy(data[])
#     notify(data) 
#     sleep(0.05)       
# end

T0 = 10

function while_run()
    while Bool(stop_butn[])==true
        data[] = monte(data[],temperature_[],T0)
        notify(data) 
        sleep(0.01)       
    end
end

while_run()
