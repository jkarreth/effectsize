if (require("testthat") && require("effectsize")) {

  # standardize.numeric -----------------------------------------------------
  test_that("standardize.numeric", {
    x <- standardize(seq(0, 1, length.out = 100))
    testthat::expect_equal(mean(x), 0, tolerance = 0.01)

    x <- standardize(seq(0, 1, length.out = 100), two_sd = TRUE)
    testthat::expect_equal(sd(x), 0.5, tolerance = 0.01)

    x <- standardize(seq(0, 1, length.out = 100), robust = TRUE)
    testthat::expect_equal(median(x), 0, tolerance = 0.01)

    x <- standardize(seq(0, 1, length.out = 100), robust = TRUE, two_sd = TRUE)
    testthat::expect_equal(mad(x), 0.5, tolerance = 0.01)

    testthat::expect_message(standardize(c(0, 0, 0, 1, 1)))
  })


  # standardize.data.frame --------------------------------------------------
  test_that("standardize.data.frame", {
    data(iris)
    x <- standardize(iris)
    testthat::expect_equal(mean(x$Sepal.Length), 0, tolerance = 0.01)
    testthat::expect_length(levels(x$Species), 3)
    testthat::expect_equal(mean(subset(x, Species == "virginica")$Sepal.Length), 0.90, tolerance = 0.01)

    testthat::skip_if_not_installed("dplyr")
    x <- standardize(dplyr::group_by(iris, Species))
    testthat::expect_equal(mean(x$Sepal.Length), 0, tolerance = 0.01)
    testthat::expect_length(levels(x$Species), 3)
    testthat::expect_equal(mean(subset(x, Species == "virginica")$Sepal.Length), 0, tolerance = 0.01)
  })


  test_that("standardize.data.frame, NAs", {
    data(iris)
    iris$Sepal.Width[c(148, 65, 33, 58, 54, 93, 114, 72, 32, 23)] <- NA
    iris$Sepal.Length[c(11, 30, 141, 146, 13, 149, 6, 8, 48, 101)] <- NA

    x <- standardize(iris)
    testthat::expect_equal(head(x$Sepal.Length), c(-0.9163, -1.1588, -1.4013, -1.5226, -1.0376, NA), tolerance = 0.01)
    testthat::expect_equal(head(x$Sepal.Width), c(1.0237, -0.151, 0.3189, 0.0839, 1.2586, 1.9635), tolerance = 0.01)
    testthat::expect_equal(mean(x$Sepal.Length), as.numeric(NA))

    x <- standardize(iris, two_sd = TRUE)
    testthat::expect_equal(head(x$Sepal.Length), c(-0.4603, -0.5811, -0.7019, -0.7623, -0.5207, NA), tolerance = 0.01)
    testthat::expect_equal(head(x$Sepal.Width), c(0.5118, -0.0755, 0.1594, 0.042, 0.6293, 0.9817), tolerance = 0.01)
    testthat::expect_equal(mean(x$Sepal.Length), as.numeric(NA))

    testthat::skip_if_not_installed("dplyr")
    x <- standardize(dplyr::group_by(iris, .data$Species))
    testthat::expect_equal(head(x$Sepal.Length), c(0.2547, -0.3057, -0.8661, -1.1463, -0.0255, NA), tolerance = 0.01)
    testthat::expect_equal(head(x$Sepal.Width), c(0.2369, -1.0887, -0.5584, -0.8235, 0.502, 1.2974), tolerance = 0.01)
    testthat::expect_equal(mean(x$Sepal.Length), as.numeric(NA))
  })


  test_that("standardize.data.frame, apend", {
    data(iris)
    iris$Sepal.Width[c(26, 43, 56, 11, 66, 132, 23, 133, 131, 28)] <- NA
    iris$Sepal.Length[c(32, 12, 109, 92, 119, 49, 83, 113, 64, 30)] <- NA

    x <- standardize(iris, append = TRUE)
    testthat::expect_equal(colnames(x), c(
      "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width",
      "Species", "Sepal.Length_z", "Sepal.Width_z", "Petal.Length_z",
      "Petal.Width_z"
    ))
    testthat::expect_equal(head(x$Sepal.Length_z), c(-0.8953, -1.1385, -1.3816, -1.5032, -1.0169, -0.5306), tolerance = 0.01)
    testthat::expect_equal(head(x$Sepal.Width_z), c(1.04, -0.1029, 0.3543, 0.1257, 1.2685, 1.9542), tolerance = 0.01)
    testthat::expect_equal(mean(x$Sepal.Length_z), as.numeric(NA))

    x <- standardize(iris, two_sd = TRUE, append = TRUE)
    testthat::expect_equal(head(x$Sepal.Length_z), c(-0.4477, -0.5692, -0.6908, -0.7516, -0.5084, -0.2653), tolerance = 0.01)
    testthat::expect_equal(head(x$Sepal.Width_z), c(0.52, -0.0514, 0.1771, 0.0629, 0.6343, 0.9771), tolerance = 0.01)
    testthat::expect_equal(mean(x$Sepal.Length_z), as.numeric(NA))

    testthat::skip_if_not_installed("dplyr")
    x <- standardize(dplyr::group_by(iris, .data$Species), append = TRUE)
    testthat::expect_equal(head(x$Sepal.Length_z), c(0.2746, -0.2868, -0.8483, -1.129, -0.0061, 1.1168), tolerance = 0.01)
    testthat::expect_equal(head(x$Sepal.Width_z), c(0.1766, -1.1051, -0.5924, -0.8487, 0.4329, 1.2019), tolerance = 0.01)
    testthat::expect_equal(mean(x$Sepal.Length_z), as.numeric(NA))
  })



  test_that("standardize.data.frame, weights", {
    x <- rexp(30)
    w <- rpois(30, 20) + 1

    expect_equal(
      sqrt(cov.wt(cbind(x, x), w)$cov[1, 1]),
      attr(standardize(x, weights = w), "scale")
    )
    expect_equal(
      standardize(x, weights = w),
      standardize(data.frame(x), weights = w)$x
    )

    # name and vector give same results
    expect_equal(
      standardize(mtcars, exclude = "cyl", weights = mtcars$cyl),
      standardize(mtcars, weights = "cyl")
    )

    testthat::skip_if_not_installed("dplyr")
    d <- dplyr::group_by(mtcars, am)
    expect_warning(standardize(d, weights = d$cyl))
  })
}
