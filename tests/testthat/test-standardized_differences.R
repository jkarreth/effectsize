if (require("testthat") && require("effectsize")) {
  test_that("cohens_d errors and warnings", {

    # Direction ---------------------------------------------------------------
    rez_t <- t.test(iris$Sepal.Length, iris$Sepal.Width)
    rez_d <- cohens_d(iris$Sepal.Length, iris$Sepal.Width)
    testthat::expect_true(sign(rez_t$statistic) == sign(rez_d$Cohens_d))


    # Errors and warnings -----------------------------------------------------
    df <- data.frame(
      a = 1:10,
      b = 2:11,
      c = rep(letters[1:2], each = 5),
      d = c("a", "b", "b", "c", "c", "b", "c", "a", "a", "b"),
      e = rep(0:1, each = 5)
    )
    a2 <- 1:11

    testthat::expect_true({
      cohens_d(a ~ c, data = df)
      TRUE
    })
    testthat::expect_true({
      cohens_d("a", "c", data = df)
      TRUE
    })
    testthat::expect_true({
      cohens_d("a", "b", data = df)
      TRUE
    })
    testthat::expect_true({
      cohens_d(a2, df$b)
      TRUE
    })
    testthat::expect_true({
      cohens_d(b ~ e, data = df)
      TRUE
    })

    testthat::expect_error(cohens_d(a ~ b, data = df))
    testthat::expect_error(cohens_d(a ~ d, data = df))
    testthat::expect_error(cohens_d("a", "d", data = df))
    testthat::expect_error(cohens_d("c", "c", data = df))
    testthat::expect_error(cohens_d(a2, df$c))

    testthat::expect_warning(cohens_d("b", "e", data = df))
  })

  test_that("cohens_d - pooled", {
    x <- cohens_d(wt ~ am, data = mtcars, pooled_sd = TRUE)
    testthat::expect_equal(colnames(x)[1], "Cohens_d")
    testthat::expect_equal(x[[1]], 1.892, tolerance = 0.001)
    testthat::expect_equal(x$CI_low, 1.030, tolerance = 0.001)
    testthat::expect_equal(x$CI_high, 2.732, tolerance = 0.001)
  })

  test_that("cohens_d - non-pooled", {
    x <- cohens_d(wt ~ am, data = mtcars, pooled_sd = FALSE)
    testthat::expect_equal(colnames(x)[1], "Cohens_d")
    testthat::expect_equal(x[[1]], 1.934, tolerance = 0.001)
    testthat::expect_equal(x$CI_low, 1.098798, tolerance = 0.001)
    testthat::expect_equal(x$CI_high, 2.833495, tolerance = 0.001)
  })

  test_that("hedges_g (and other bias correction things", {
    x <- hedges_g(wt ~ am, data = mtcars, correction = 1)
    testthat::expect_equal(colnames(x)[1], "Hedges_g")
    testthat::expect_equal(x[[1]], 1.844, tolerance = 0.001)
    testthat::expect_equal(x$CI_low, 1.004, tolerance = 0.001)
    testthat::expect_equal(x$CI_high, 2.664, tolerance = 0.001)

    x <- hedges_g(wt ~ am, data = mtcars, correction = 2)
    testthat::expect_equal(colnames(x)[1], "Hedges_g")
    testthat::expect_equal(x[[1]], 1.786, tolerance = 0.001)
    testthat::expect_equal(x$CI_low, 0.972, tolerance = 0.001)
    testthat::expect_equal(x$CI_high, 2.579, tolerance = 0.001)

    testthat::expect_warning(hedges_g(wt ~ am, data = mtcars, correction = TRUE))
    testthat::expect_warning(cohens_d(wt ~ am, data = mtcars, correction = TRUE))
    testthat::expect_warning(glass_delta(wt ~ am, data = mtcars, correction = TRUE))
  })

  test_that("glass_delta", {
    x <- glass_delta(wt ~ am, data = mtcars)
    testthat::expect_equal(colnames(x)[1], "Glass_delta")
    testthat::expect_equal(x[[1]], 2.200, tolerance = 0.001)
    testthat::expect_equal(x$CI_low, 1.292, tolerance = 0.001)
    testthat::expect_equal(x$CI_high, 3.086, tolerance = 0.001)

    # must be 2 samples
    testthat::expect_error(glass_delta(1:10))
  })


  test_that("fixed values", {
    testthat::skip_if_not_installed("bayestestR")

    x1 <- bayestestR::distribution_normal(1e4, mean = 0, sd = 1)
    x2 <- bayestestR::distribution_normal(1e4, mean = 1, sd = 1)
    testthat::expect_equal(cohens_d(x1, x2)$Cohens_d, -1, tolerance = 1e-3)


    x1 <- bayestestR::distribution_normal(1e4, mean = 0, sd = 1)
    x2 <- bayestestR::distribution_normal(1e4, mean = 1.5, sd = 2)

    testthat::expect_equal(cohens_d(x1, x2)$Cohens_d, -sqrt(0.9), tolerance = 1e-2)
    testthat::expect_equal(glass_delta(x2, x1)$Glass_delta, 1.5, tolerance = 1e-2)
  })

  test_that("Missing values", {
    x <- c(1, 2, NA, 3)
    y <- c(1, 1, 2, 3)
    testthat::expect_equal(cohens_d(x, y)[[1]], 0.2564946, tolerance = 0.01) # indep
    testthat::expect_equal(cohens_d(x, y, paired = TRUE)[[1]], 0.5773503, tolerance = 0.01) # paired

    # no length problems
    testthat::expect_error(cohens_d(mtcars$mpg - 23), regexp = NA)
  })
}
