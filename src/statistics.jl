"""
    varN(BinningAnalysis[, lvl = 0])

Calculates the variance/N of a given level in the Binning Analysis.
"""
function varN(
        B::BinnerA{N, T},
        lvl::Int64 = 0
    ) where {N, T <: Real}

    # lvl = 1 <=> original values
    # correct variance:
    # (∑ xᵢ^2) / (N-1) - (∑ xᵢ)(∑ xᵢ) / (N(N-1))
    (
        B.x2_sum[lvl+1] / (B.count[lvl+1] - 1) -
        B.x_sum[lvl+1]^2 / ((B.count[lvl+1] - 1) * B.count[lvl+1])
    ) / B.count[lvl+1]
end

function varN(
        B::BinnerA{N, T},
        lvl::Int64 = 0
    ) where {N, T <: Complex}

    # lvl = 1 <=> original values
    (
        (real(B.x2_sum[lvl+1]) + imag(B.x2_sum[lvl+1])) /
            (B.count[lvl+1] - 1) -
        (real(B.x_sum[lvl+1])^2 + imag(B.x_sum[lvl+1])^2) /
            ((B.count[lvl+1] - 1) * B.count[lvl+1])
    ) / B.count[lvl+1]
end

function varN(
        B::BinnerA{N, <: AbstractArray{T, D}},
        lvl::Int64 = 0
    ) where {N, D, T <: Real}

    # lvl = 1 <=> original values
    # correct variance:
    # (∑ xᵢ^2) / (N-1) - (∑ xᵢ)(∑ xᵢ) / (N(N-1))
    @. (
        B.x2_sum[lvl+1] / (B.count[lvl+1] - 1) -
        B.x_sum[lvl+1]^2 / ((B.count[lvl+1] - 1) * B.count[lvl+1])
    ) / B.count[lvl+1]
end

function varN(
        B::BinnerA{N, <: AbstractArray{T, D}},
        lvl::Int64 = 0
    ) where {N, D, T <: Complex}

    # lvl = 1 <=> original values
    @. (
        (real(B.x2_sum[lvl+1]) + imag(B.x2_sum[lvl+1])) /
            (B.count[lvl+1] - 1) -
        (real(B.x_sum[lvl+1])^2 + imag(B.x_sum[lvl+1])^2) /
            ((B.count[lvl+1] - 1) * B.count[lvl+1])
    ) / B.count[lvl+1]
end


"""
    var(BinningAnalysis[, lvl = 0])

Calculates the variance of a given level in the Binning Analysis.
"""
function var(
        B::BinnerA{N, T},
        lvl::Int64 = 0
    ) where {N, T <: Real}

    B.x2_sum[lvl+1] / (B.count[lvl+1] - 1) -
    B.x_sum[lvl+1]^2 / ((B.count[lvl+1] - 1) * B.count[lvl+1])
end

function var(
        B::BinnerA{N, T},
        lvl::Int64 = 0
    ) where {N, T <: Complex}

    (real(B.x2_sum[lvl+1]) + imag(B.x2_sum[lvl+1])) /
        (B.count[lvl+1] - 1) -
    (real(B.x_sum[lvl+1])^2 + imag(B.x_sum[lvl+1])^2) /
        ((B.count[lvl+1] - 1) * B.count[lvl+1])
end

function var(
        B::BinnerA{N, <: AbstractArray{T, D}},
        lvl::Int64 = 0
    ) where {N, D, T <: Real}

    @. B.x2_sum[lvl+1] / (B.count[lvl+1] - 1) -
    B.x_sum[lvl+1]^2 / ((B.count[lvl+1] - 1) * B.count[lvl+1])
end

function var(
        B::BinnerA{N, <: AbstractArray{T, D}},
        lvl::Int64 = 0
    ) where {N, D, T <: Complex}

    @. (real(B.x2_sum[lvl+1]) + imag(B.x2_sum[lvl+1])) /
        (B.count[lvl+1] - 1) -
    (real(B.x_sum[lvl+1])^2 + imag(B.x_sum[lvl+1])^2) /
        ((B.count[lvl+1] - 1) * B.count[lvl+1])
end


"""
    all_vars(BinningAnalysis)

Calculates the variance for each level of the Binning Analysis.
"""
function all_vars(B::BinnerA{N}) where {N}
    [var(B, lvl) for lvl in 0:N-1 if B.count[lvl+1] > 0]
end


"""
    all_varNs(BinningAnalysis)

Calculates the variance/N for each level of the Binning Analysis.
"""
function all_varNs(B::BinnerA{N}) where {N}
    [varN(B, lvl) for lvl in 0:N-1 if B.count[lvl+1] > 0]
end


################################################################################


# NOTE works for all
"""
    mean(BinningAnalysis[, lvl=0])

Calculates the mean for a given level in the Binning Analysis.
"""
function mean(B::BinnerA, lvl::Int64 = 0)
    B.x_sum[lvl+1] / B.count[lvl+1]
end


# NOTE works for all
"""
    all_means(BinningAnalysis)

Calculates the mean for each level of the Binning Analysis.
"""
function all_means(B::BinnerA{N}) where {N}
    [mean(B, lvl) for lvl in 0:N-1 if B.count[lvl+1] > 0]
end


################################################################################


"""
    tau(BinningAnalysis[, lvl=0])

Calculates the autocorrelation time tau for a given binning level.
"""
function tau(B::BinnerA, lvl::Int64 = 0)
    var_0 = varN(B, 0)
    var_l = varN(B, lvl)
    0.5 * (var_l / var_0 - 1)
end


"""
    all_taus(BinningAnalysis)

Calculates the autocorrelation time tau for each level of the Binning Analysis.
"""
function all_taus(B::BinnerA{N}) where {N}
    [tau(B, lvl) for lvl in 0:N-1 if B.count[lvl+1] > 0]
end


################################################################################


# Heuristic for selecting the level with the (presumably) most reliable
# standard error estimate:
# Take the highest lvl with at least 32 bins.
# (Chose 32 based on https://doi.org/10.1119/1.3247985)
function _select_lvl_for_std_error(B::BinnerA{N,T})::Int64 where {N, T}
    n = B.count[1]
    n == 0 && (return 0)
    max_bs = n / 32

    i = findlast(bs -> bs <= max_bs, 2 .^ (0:N))
    isnothing(i) ? 1 : i
end

"""
    std_error(BinningAnalysis[, lvl=0])

Calculates the standard error for a given level.
"""
function std_error(B::BinnerA{N, T}, lvl::Int64=_select_lvl_for_std_error(B)) where {N, T <: Number}
    sqrt(varN(B, lvl))
end
function std_error(B::BinnerA{N, T}, lvl::Int64=_select_lvl_for_std_error(B)) where {N, T <: AbstractArray}
    sqrt.(varN(B, lvl))
end


"""
    all_std_errors(BinningAnalysis)

Calculates the standard error for each level of the Binning Analysis.
"""
function all_std_errors(B::BinnerA{N, T}) where {N, T <: Number}
    map(sqrt, all_varNs(B))
end
function all_std_errors(B::BinnerA{N, T}) where {N, T <: AbstractArray}
    map(x -> sqrt.(x), all_varNs(B))
end


"""
    convergence(BinningAnalysis, lvl)

Computes the difference between the variance of this lvl and the last,
normalized to the last lvl. If this value tends to 0, the Binning Analysis has
converged.
"""
function convergence(B::BinnerA{N, T}, lvl::Int64) where {N, T <: Number}
    abs((varN(B, lvl) - varN(B, lvl-1)) / varN(B, lvl-1))
end
function convergence(B::BinnerA{N, T}, lvl::Int64) where {N, T <: AbstractArray}
    mean(abs.((varN(B, lvl) .- varN(B, lvl-1)) ./ varN(B, lvl-1)))
end

"""
    has_converged(BinningAnalysis, lvl[, threshhold = 0.05])

Returns true if the Binning Analysis has converged for a given lvl.
"""
function has_converged(B::BinnerA, lvl::Int64, threshhold::Float64 = 0.05)
    convergence(B, lvl) <= threshhold
end
