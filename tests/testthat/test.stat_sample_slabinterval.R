# Tests for sample distribution plots
#
# Author: mjskay
###############################################################################

library(dplyr)

context("stat_sample_")

test_that("vanilla stat_slabinterval works", {
  skip_if_no_vdiffr()


  set.seed(1234)
  p = tribble(
    ~dist,  ~x,
    "norm", rnorm(100),
    "t",    rt(100, 3)
  ) %>%
    unnest(x) %>%
    ggplot() +
    scale_slab_alpha_continuous(range = c(0,1))

  vdiffr::expect_doppelganger("vanilla stat_slabinterval",
    p + stat_slabinterval(aes(x = dist, y = x), n = 20, slab_function = sample_slab_function)
  )
})

test_that("gradientinterval works", {
  skip_if_no_vdiffr()


  set.seed(1234)
  p = tribble(
    ~dist,  ~x,
    "norm", rnorm(100),
    "t",    rt(100, 3)
  ) %>%
    unnest(x) %>%
    ggplot() +
    scale_slab_alpha_continuous(range = c(0,1))

  vdiffr::expect_doppelganger("gradientinterval with two groups",
    p + stat_gradientinterval(aes(x = dist, y = x), n = 20, fill_type = "segments")
  )
  vdiffr::expect_doppelganger("gradientintervalh with two groups",
    p + stat_gradientinterval(aes(y = dist, x = x), n = 20, fill_type = "segments")
  )

  # N.B. the following two tests are currently a bit useless as vdiffr doesn't
  # support linearGradient yet, but leaving them here so that once it does we
  # have tests for this.
  vdiffr::expect_doppelganger("fill_type = gradient with two groups",
    p + stat_gradientinterval(aes(x = dist, y = x), n = 20, fill_type = "gradient")
  )
  vdiffr::expect_doppelganger("fill_type = gradient with two groups, h",
    p + stat_gradientinterval(aes(y = dist, x = x), n = 20, fill_type = "gradient")
  )

})

test_that("histinterval and slab work", {
  skip_if_no_vdiffr()


  set.seed(1234)
  p = tribble(
    ~dist,  ~x,
    "norm", rnorm(100),
    "t",    rt(100, 3)
  ) %>%
    unnest(x) %>%
    ggplot()

  vdiffr::expect_doppelganger("histinterval with outline",
    p + stat_histinterval(aes(x = dist, y = x), slab_color = "black")
  )
  vdiffr::expect_doppelganger("histintervalh with outline",
    p + stat_histinterval(aes(y = dist, x = x), slab_color = "black")
  )

  vdiffr::expect_doppelganger("slab with outline",
    p + stat_slab(aes(x = dist, y = x), n = 20, slab_color = "black")
  )
  vdiffr::expect_doppelganger("slabh with outline",
    p + stat_slab(aes(y = dist, x = x), n = 20, slab_color = "black")
  )

})

test_that("scale transformation works", {
  skip_if_no_vdiffr()



  p_log = data.frame(x = qlnorm(ppoints(200), log(10), 2 * log(10))) %>%
    ggplot(aes(y = "a", x = x)) +
    scale_x_log10(breaks = 10^seq(-5,7, by = 2))

  vdiffr::expect_doppelganger("halfeyeh log scale transform",
    p_log + stat_halfeye(point_interval = mode_hdci, n = 50)
  )

  vdiffr::expect_doppelganger("ccdfintervalh log scale transform",
    p_log + stat_ccdfinterval(point_interval = mean_hdi, n = 50)
  )

  vdiffr::expect_doppelganger("histintervalh log scale transform",
    p_log + stat_histinterval(point_interval = median_qi, n = 50)
  )

})

test_that("pdf and cdf aesthetics work", {
  skip_if_no_vdiffr()


  p = data.frame(
    x = c("a", "b"),
    y = qnorm(ppoints(100), c(1, 2), 2)
  ) %>%
    ggplot(aes(x = x, y = y))

  vdiffr::expect_doppelganger("pdf and cdf on a sample slabinterval",
    p + stat_sample_slabinterval(aes(fill = x, thickness = stat(pdf), slab_alpha = stat(cdf)), n = 20) + geom_point()
  )
})

test_that("constant distributions work", {
  skip_if_no_vdiffr()


  p = data.frame(
    x = c("constant = 1", "normal(2,1)"),
    # sd of 0 will generate constant dist
    y = qnorm(ppoints(100), mean = c(1, 2), sd = c(0, 1))
  ) %>%
    ggplot(aes(x = x, y = y))

  vdiffr::expect_doppelganger("constant dist on halfeye",
    p + stat_sample_slabinterval(n = 20)
  )

  vdiffr::expect_doppelganger("constant dist on ccdf",
    p + stat_ccdfinterval()
  )

})

