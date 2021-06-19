### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ c8c6c2cf-7ae5-42a0-a9a0-060f1c697e07
begin
	using Plots
	using Statistics
	#using StatPlots
end

# ╔═╡ 9ec5e802-2b1e-4b0d-85f6-0aafd983008b
pgfplotsx()

# ╔═╡ b83cfe4d-a8e7-40e3-b249-19d117aecaf9
fig_dir = "figures/"

# ╔═╡ 2fe03b0e-2a2f-4ea9-95f8-52355c7c5559
fig_ext = "tikz"

# ╔═╡ 0f65d455-2cbe-4e27-b9cb-7f2e60a8471e
save_plots = true

# ╔═╡ e1550af6-d01b-11eb-33d9-fb6ffe04aaca
data = [
1 1.127200 0.351392 
2 1.490560 0.713696 
4 1.548384 0.844960 
8 1.562880 0.856544 
16 1.872608 1.157216 
32 1.877632 1.166976 
64 1.941376 1.235232 
128 2.204736 1.472512 
256 4.740416 3.963904 
512 15.359328 13.661536 
1024 56.678177 51.261250 
2048 215.084122 194.488678 
4096 803.822205 723.709534 
8192 3202.430908 2887.775635
#10000 9437.689453 9092.725586
	]

# ╔═╡ ba589bf5-886b-4b0c-a329-8c3044e68a67
begin
	size = data[:,1]
	time_total = data[:,2]
	time_kernel = data[:,3]
end

# ╔═╡ 99d71bda-a36c-4d0d-bc5c-223927416e87
plot1 = let
	ticks = Int.(ceil.(log2.(size)))
	plot(xscale=:log2, yscale=:log10,
		ylabel="Time (ms)",
		xlabel="Grid size",
		legend=:topleft,
		xticks=(2 .^ticks, ["2^{$i}" for i in 2 .*ticks]),
		xrange=2 .^(ticks[1], ticks[end]), 
	)
	scatter!(size, time_kernel, label="Kernel only")
	scatter!(size, time_total, label="Total time (kernel + IO)")
	
end

# ╔═╡ 5a804de3-059d-4822-b7d7-637215bea96b
data_seq = [
1 0.144448 
2 0.904864 
4 4.065440 
8 16.668287 
16 66.733055 
32 267.999725 
64 1078.171997 
128 4313.813477 
256 17277.890625
]

# ╔═╡ cce62af6-0c81-4b02-a50f-c077f159e6e0
begin
	size_seq = data_seq[:,1]
	time_seq = data_seq[:,2]
end

# ╔═╡ 2700bab0-9960-4415-9d23-2f0f86d91399
2 .^(length(size_seq):length(size))

# ╔═╡ 68a6071a-bf59-4e6f-986c-8f64a1a477f8
interpol(x) = (x^2)*0.25

# ╔═╡ a532a687-9f72-4f36-b44f-06da20b688f4
plot2 = let
	points = 1:length(size_seq)
	plot(xscale=:log2, yscale=:log10,
		ylabel="Time (ms)",
		xlabel="Grid size",
		legend=:topleft,
		xticks=(size_seq, ["2^{$i}" for i in 2 .*Int.(log2.(size_seq))]),
	)
	scatter!(size_seq, time_seq, label="Sequential time")
	plot!(size, interpol.(size))
end

# ╔═╡ 57495b05-f3bd-4714-a1c6-a680f967c46e
let
	plot!()
	plot(plot1, plot2)
end

# ╔═╡ 0f191082-d197-4ef9-809c-c6d609905cc2
regresions = let
	plot(xscale=:log2, yscale=:log10,
		ylabel="Execution time (ms)",
		xlabel="Grid size",
		legend=:topleft,
		xticks=(size, ["2^{$i}" for i in 2 .*Int.(log2.(size))]),
		yminorgrid=true,
		#ylims=(0,1000)
	)
	scatter!(size, time_total, label="CUDA execution time (total)")
	#scatter!(size, time_kernel, label="Temps CUDA (kernel)")
	
	points = 1:length(size_seq)
	scatter!(size_seq, time_seq, label="Sequential execution time")
	plot!(size, interpol.(size), label="Quadratic fit on sequential time (\$ax^2 + b)\$")
	#plot!(size, interpol.(size)/1e4, label="\$0.75x^2/1000\$")
	#plot!(size, size.^(1/4) .*2, label="\$2\\sqrt[4] x\$")
end

# ╔═╡ 7adef6c4-cad8-493d-9ca4-545574457a2c
time_seq[end]/time_seq[end-1]

# ╔═╡ d279f53d-8445-407f-a112-49a8bce4a2bc
time_seq_ext = let
	ext = vcat(time_seq, interpol.( 2 .^((length(size_seq)):length(size)-1) ))
end

# ╔═╡ e176a529-e535-4849-b9af-c87c70bcd374
plot_speedup = let
	plot(xscale=:log2, yscale=:log10,
		ylabel="Speedup",
		xlabel="Grid size",
		legend=:bottomright,
		xticks=(size, ["2^{$i}" for i in 2 .*Int.(floor.(log2.(size)))]),
		#minorgrid=true,
	)
	scatter!(size, time_seq_ext ./ time_total , label="Speedup")
	hline!([10240], label="Maximum Theoretical Speedup (10240)")
	hline!([1], label="Speedup == 1")
	last_speed = Int(round(time_seq_ext[end]/time_total[end]))
	hline!([last_speed], label="Achieved speedup: $last_speed", style=:dot)
	#hline!([1], label="No speedup 1")
	#plot!(size, size .^2 .*0.75)
end

# ╔═╡ 3797d083-f849-46b1-81fc-e25f4960c71d
begin
	if save_plots
		savefig(plot1, fig_dir*"e_time_kernel.$fig_ext")
		savefig(plot_speedup, fig_dir*"speedup.$fig_ext")
		savefig(regresions, fig_dir*"e_time_all.$fig_ext")
	end
end

# ╔═╡ 16607051-7cd5-451d-b18c-091f3b74c348


# ╔═╡ 731ccdfd-054b-4cf6-9c11-157aef399c2d
speedup = time_seq_ext[end]/time_total[end]

# ╔═╡ 58328fcd-fe14-47a0-ba7c-cd28ed84e1e7
time_seq_ext ./ time_total

# ╔═╡ d20ce6fb-8e15-4d4c-8dac-566816d5f584
time_seq_ext[end]/1000

# ╔═╡ 2b3d8935-c914-4c24-b62c-59b50a39f791
time_total[end]

# ╔═╡ 0721cf34-8b4e-41ee-8bcd-532954b36f7c
begin
	data_blocks = [
		1 4096 341443.593750 341253.531250
	2 4096 85677.710938 85488.867188
	4 4096 21851.068359 21661.205078
	8 4096 11362.608398 11172.577148
	16 4096 11382.617188 11192.669922
		]
	data_blocks_extra = [
		17 4096 12399.887695 12210.659180
	19 4096 12113.488281 11922.862305
	20 4096 11192.813477 11003.361328
	#21 4096 11170.774414 10980.695312
	21 4096 11170.983398 10981.176758
	22 4096 11761.817383 11571.402344
	23 4096 11532.744141 11344.122070
	25 4096 11560.190430 11369.271484
	27 4096 11528.493164 11338.803711
		]
end

# ╔═╡ b85ee1ea-51ab-46a7-9188-bf3ca6fab8c6
begin
	blocks = Int.(data_blocks[:,1])
	blocks_time = data_blocks[:,3]
	
	blocks_ext = Int.(data_blocks_extra[:,1])
	blocks_time_ext = data_blocks_extra[:,3]
end

# ╔═╡ 22d65dcc-8ab7-4e41-b966-1a15e6517f99
plot_blocks = let
	block_ticks = vcat(blocks, [32])
	scatter(
		ylabel="Speedup",
		ylim=(1,2880),
		xlabel="Block size",
		xscale=:log2, yscale=:log10,
		xticks=(block_ticks, ["\$$i\\times $i\$" for i in block_ticks]),
		xrange=(1, 32),
		blocks, time_seq_ext[end]./blocks_time,
		legend=:topleft,
		label="Blocks pot\\`encia de 2"
	)
	hline!([2880], label="M\\`axim te\\`oric")
	scatter!(blocks_ext, time_seq_ext[end]./blocks_time_ext,
		markershape=:x, label="",
	)
end

# ╔═╡ 6e92b007-429a-4c3e-9802-9c039c499f51
time_seq_ext[end]./blocks_time

# ╔═╡ dccfc599-cbb8-432a-9e87-5826b84fea99
time_seq_ext ./ time_total

# ╔═╡ 953199a9-a421-4d9a-97ad-25ec534404ec
begin
	data_primes_old = [
		797  448.455811 439.439301
		907  572.867310 562.317627
		1000 690.564270 676.813721
		1103 842.306030 826.190308
		1201 999.436218 980.383606

		512 187.390945 182.547974 
		597 246.296539 240.497253 
		696 340.080811 331.270691 
		812 451.905914 441.526733 
		948 619.727600 606.135193 
		1105 821.864746 805.673401 
		1290 1121.761597 1099.667358 
		1505 1520.421753 1491.902100 
		1755 2048.018066 2009.800171 
		2048 2793.973633 2743.025635

		512 184.995300 179.941345
		1024 724.218445 710.461853
		2048 2869.978271 2821.136963
	]
	
	data_primes = [
		550 215.557404 210.466309 
		592 246.088058 239.653091 
		637 283.702393 277.357758 
		685 321.003662 313.429352 
		737 383.826843 375.993896 
		793 426.113312 416.554443 
		853 498.415527 487.610535 
		917 565.194946 552.780762 
		987 655.436279 642.562927 

		1062 765.901306 750.118225 
		1142 881.800842 863.867188 
		1228 1013.835938 994.326355 
		1321 1161.895874 1140.134888 
		1421 1358.046753 1332.230225 
		1529 1570.552124 1540.746826 
		1645 1823.423950 1790.111206 
		1769 2096.983398 2058.634766 
		1903 2419.246338 2375.385254
	]

	data_primes_2 = [
		512 187.596741 182.867737 
		1024 713.867493 700.067810
		2048 2804.512939 2753.595215
	]
end

# ╔═╡ 954b82e5-d527-4057-84b1-4d29fb4c25ce
begin
	lines_primes = data_primes[:,1]
	time_primes = data_primes[:,2]
	
	lines_primes_2 = data_primes_2[:,1]
	time_primes_2 = data_primes_2[:,2] 
end

# ╔═╡ d1670941-24dc-40fd-8f8d-7a148abef1db
let
	points = 1:length(size)
	scatter(
		#xticks = lines_primes,
		lines_primes,
		interpol.(lines_primes)./time_primes,
		#time_primes,
		ylabel = "Speedup",
		xlabel = "Mida problema",
		label = "Mides arbitr\\`aries",
		yrange = (1000, 1200),
		xscale=:log2,
		yscale=:log10,
		legend=:topleft,
	)
	scatter!(
		lines_primes_2,
		interpol.(lines_primes_2)./time_primes_2,
		label="Pot\\`encies de 2",
	)
end

# ╔═╡ aaf1118f-2e0a-4c35-b8ef-0f4356956143
Int.(floor.(2 .^LinRange(9, 11, 20)))

# ╔═╡ d84e6f05-39fb-457f-8517-5e0aeba16040
data_pinned = [
11171.843750
11226.105469
11171.359375
11171.605469
11359.678711
11170.466797
11171.806641
11170.234375
11170.007812
11171.120117
	]

# ╔═╡ 5683b06e-0e48-4717-a3ae-b3b21ce39e4d
data_nopinned = [
11240.915039
11240.309570
11240.884766
11240.284180
11240.684570
11239.976562
11238.617188
11240.746094
11239.931641
11239.740234
	]

# ╔═╡ ebcf19f8-8180-46c8-b404-98905d1f542c
plot_pinned = let 
	width = 0.4
	bar([1], [mean(data_nopinned)],
		bar_width=width,
		ylim=(10800, 11300),
		xticks = ([1, 2], ["NO-PINNED", "PINNED"]),
		label="NO-PINNED",
		ylabel = "Execution time (ms)",
		legend=:topright,
		yerror = std(data_nopinned),
		xlims = (0, 3)
	)
	bar!([2], [mean(data_pinned)],
		label="PINNED",
		bar_width=width,
		yerror = std(data_pinned),
	)
	
end

# ╔═╡ 1291a71f-26fe-47a0-9c69-f5b48c3a0fc6
std(data_pinned)

# ╔═╡ 844d0211-3263-4f9b-bd57-72f593adb0b1
data_multi = [
2 450.219940 1.904672       
4 447.502380 3.199296       
8 444.919830 3.154976       
16 445.142365 3.923328      
32 455.878265 4.385888      
64 455.551331 4.928832      
128 455.272308 5.359328     
256 451.623169 13.786816    
512 497.023224 46.506336    
1024 630.474426 170.596359  
2048 1149.290771 645.896790 
4096 3186.239746 2528.348877
8192 11307.819336 10102.050781
	]

# ╔═╡ 6e91b8c2-c1f9-494d-869c-239316cbd072
begin
	size_multi = data_multi[:,1]
	time_multi_total = data_multi[:,2]
	time_multi_kernel = data_multi[:,3]
end

# ╔═╡ 8d74e93f-40b8-45ae-97c6-fb6eeb82209d
time_seq_ext_multi = vcat(time_seq_ext[2:end], interpol.([8192]))

# ╔═╡ f1ca5b1b-cf55-4a69-9402-7c220d7fbb61
plot_multi = let
	plot(xscale=:log2, yscale=:log10,
		ylabel="Speedup",
		xlabel="Mida problema",
		legend=:bottomright,
		xticks=(size_multi, ["2^{$i}" for i in Int.(log2.(size_multi))]),
	)
	scatter!(size, time_seq_ext./time_total, label="Temps total (1 GPU)")
	#scatter!(size, time_seq_ext./time_kernel, label="Temps kernel (1 GPU)")
	
	scatter!(size_multi, time_seq_ext_multi./time_multi_total, label="Temps total (4 GPU)")
	#scatter!(size_multi, time_seq_ext[2:end]./time_multi_kernel, label="Temps kernel (4 GPU)")
	
		
	hline!([2880], label="M\\`axim t\\`eoric 1 GPU")
	hline!([2880*4], label="M\\`axim t\\`eoric 4 GPU")
	hline!([1], label="", color=:black)
end

# ╔═╡ ddb0110c-2111-4e94-8ad6-0ad867137f57
speedup_multi = interpol(4096)/time_multi_total[end-1]

# ╔═╡ 2912a0c0-50f5-46bd-9d15-14b7a8c726ee
time_seq_ext_multi./time_multi_total

# ╔═╡ 3c0fabb6-ed95-44ff-b6be-3931ee7dd9f3
interpol(8192)/time_multi_total[end]

# ╔═╡ 415f9a0a-8fe0-4d3a-9dc5-27de3cd1a75e
speedup_normal = interpol(4096)/time_total[end]

# ╔═╡ e9b09e01-a437-4e4b-b2fa-92680978d415
speedup_multi/speedup_normal

# ╔═╡ bf1a22f7-a6e1-4473-8bdf-92d295bcd1ee
length(size_multi)

# ╔═╡ d84a53df-aa9b-4edb-921b-b9a8727dc424
length(time_seq_ext_multi)

# ╔═╡ e66a12d8-bcd7-4d92-8be8-be7e1eff4be4
time_seq_ext

# ╔═╡ d8f3e6f0-3e0c-48d9-b615-62d842474cd1
plot_multi_overhead = let
	plot(xscale=:log2, yscale=:log10,
		yminorgrid=true,
		ylabel="Temps (ms)",
		xlabel="Mida problema",
		legend=:bottomright,
		xticks=(size_multi, ["2^{$i}" for i in Int.(log2.(size_multi))]),
	)
	scatter!(size_multi, time_multi_total, label="Temps total (4 GPU)")
	scatter!(size_multi, time_multi_kernel, label="Temps kernel (4 GPU)")
end

# ╔═╡ 355d886f-5177-4723-9bcb-6c16019b606f
percent_kernel = scatter(
	xscale=:log2,
	#yscale=:log10,
	#yflip=true,
	#yrange=(1, 1e4),
	yrange=(0,100),
	size_multi,  (time_multi_kernel) ./time_multi_total .* 100 , label="Overhead 4 GPU",
	xticks=(size_multi, ["2^{$i}" for i in Int.(log2.(size_multi))]),
	ylabel="Percentatge de temps kernel vs. total (4 GPU)",
	legend=:none,
)

# ╔═╡ 6de826a4-a4d2-4a1f-8de0-db47abc916c0
data_streams = [
512 4835.691406 4830.048828 
256 4706.396484 4702.251465 
128 4711.477539 4707.451172 
64 4693.247559 4689.060547 
32 4664.387207 4660.096191 
16 4693.378418 4689.079102 
8 4699.671875 4695.623535 
4 4712.606934 4708.504883 
2 4718.174805 4713.987305 
1 4719.184570 4714.729492
	]

# ╔═╡ 41d080e3-bd93-46bc-b356-930efe53a75c
begin
	num_streams = data_streams[:,1]
	time_streams = data_streams[:,2]
end

# ╔═╡ b1b7389e-1542-42a5-b131-a7cdfcd68824
plot_streams = let
	tt = time_total[11]
	plot(xscale=:log2, yscale=:log10,
		ylims=(1e-1, 1),
		ylabel="Speedup",
		xlabel="Nombre d'streams",
		legend=:topright,
		xticks=(num_streams, ["2^{$i}" for i in Int.(log2.(num_streams))]),
	)
	scatter!(num_streams, tt./time_streams, label="Temps execuci\\'o Streams")
	
	hline!([0.99], label="No speedup")
	#scatter!(size, time_seq_ext./time_kernel, label="Temps kernel (1 GPU)")
	#hline!([time_total[11]], label="Temps execuci\\'o sense Streams")
end

# ╔═╡ c6b660e3-2899-45ec-b1f7-e1fda2e2c241
time_total[11]

# ╔═╡ Cell order:
# ╠═c8c6c2cf-7ae5-42a0-a9a0-060f1c697e07
# ╠═9ec5e802-2b1e-4b0d-85f6-0aafd983008b
# ╠═b83cfe4d-a8e7-40e3-b249-19d117aecaf9
# ╠═2fe03b0e-2a2f-4ea9-95f8-52355c7c5559
# ╠═0f65d455-2cbe-4e27-b9cb-7f2e60a8471e
# ╠═3797d083-f849-46b1-81fc-e25f4960c71d
# ╠═e1550af6-d01b-11eb-33d9-fb6ffe04aaca
# ╠═ba589bf5-886b-4b0c-a329-8c3044e68a67
# ╠═99d71bda-a36c-4d0d-bc5c-223927416e87
# ╠═5a804de3-059d-4822-b7d7-637215bea96b
# ╠═cce62af6-0c81-4b02-a50f-c077f159e6e0
# ╠═a532a687-9f72-4f36-b44f-06da20b688f4
# ╠═57495b05-f3bd-4714-a1c6-a680f967c46e
# ╠═0f191082-d197-4ef9-809c-c6d609905cc2
# ╠═2700bab0-9960-4415-9d23-2f0f86d91399
# ╠═68a6071a-bf59-4e6f-986c-8f64a1a477f8
# ╠═7adef6c4-cad8-493d-9ca4-545574457a2c
# ╠═d279f53d-8445-407f-a112-49a8bce4a2bc
# ╠═e176a529-e535-4849-b9af-c87c70bcd374
# ╠═16607051-7cd5-451d-b18c-091f3b74c348
# ╠═731ccdfd-054b-4cf6-9c11-157aef399c2d
# ╠═58328fcd-fe14-47a0-ba7c-cd28ed84e1e7
# ╠═d20ce6fb-8e15-4d4c-8dac-566816d5f584
# ╠═2b3d8935-c914-4c24-b62c-59b50a39f791
# ╠═0721cf34-8b4e-41ee-8bcd-532954b36f7c
# ╠═b85ee1ea-51ab-46a7-9188-bf3ca6fab8c6
# ╠═22d65dcc-8ab7-4e41-b966-1a15e6517f99
# ╠═6e92b007-429a-4c3e-9802-9c039c499f51
# ╠═dccfc599-cbb8-432a-9e87-5826b84fea99
# ╠═953199a9-a421-4d9a-97ad-25ec534404ec
# ╠═954b82e5-d527-4057-84b1-4d29fb4c25ce
# ╠═d1670941-24dc-40fd-8f8d-7a148abef1db
# ╠═aaf1118f-2e0a-4c35-b8ef-0f4356956143
# ╠═d84e6f05-39fb-457f-8517-5e0aeba16040
# ╠═5683b06e-0e48-4717-a3ae-b3b21ce39e4d
# ╠═ebcf19f8-8180-46c8-b404-98905d1f542c
# ╠═1291a71f-26fe-47a0-9c69-f5b48c3a0fc6
# ╠═844d0211-3263-4f9b-bd57-72f593adb0b1
# ╠═6e91b8c2-c1f9-494d-869c-239316cbd072
# ╠═f1ca5b1b-cf55-4a69-9402-7c220d7fbb61
# ╠═8d74e93f-40b8-45ae-97c6-fb6eeb82209d
# ╠═ddb0110c-2111-4e94-8ad6-0ad867137f57
# ╠═2912a0c0-50f5-46bd-9d15-14b7a8c726ee
# ╠═3c0fabb6-ed95-44ff-b6be-3931ee7dd9f3
# ╠═415f9a0a-8fe0-4d3a-9dc5-27de3cd1a75e
# ╠═e9b09e01-a437-4e4b-b2fa-92680978d415
# ╠═bf1a22f7-a6e1-4473-8bdf-92d295bcd1ee
# ╠═d84a53df-aa9b-4edb-921b-b9a8727dc424
# ╠═e66a12d8-bcd7-4d92-8be8-be7e1eff4be4
# ╠═d8f3e6f0-3e0c-48d9-b615-62d842474cd1
# ╠═355d886f-5177-4723-9bcb-6c16019b606f
# ╠═6de826a4-a4d2-4a1f-8de0-db47abc916c0
# ╠═41d080e3-bd93-46bc-b356-930efe53a75c
# ╠═b1b7389e-1542-42a5-b131-a7cdfcd68824
# ╠═c6b660e3-2899-45ec-b1f7-e1fda2e2c241
