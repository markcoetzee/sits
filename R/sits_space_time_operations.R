#' @title Coordinate transformation (lat/long to X/Y)
#' @name .sits_latlong_to_proj
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Transform a latitude and longitude coordinate to a XY projection coordinate
#'
#' @param longitude       double - the longitude of the chosen location
#' @param latitude        double - the latitude of the chosen location
#' @param crs             projection definition to be converted to
#' @return xy             matrix with X/Y coordinates
.sits_latlong_to_proj <- function(longitude, latitude, crs) {


    st_point <- sf::st_point(c(longitude, latitude))
    lat_long <- sf::st_sfc(st_point, crs = "+init=epsg:4326")

    obj.sf <- sf::st_transform(lat_long, crs = crs)

    xy <- sf::st_coordinates(obj.sf)

    return(xy)

}
#' @title Coordinate transformation (X/Y to lat/long)
#' @name .sits_proj_to_latlong
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Transform a latitude and longitude coordinate to a XY projection coordinate
#'
#' @param x               double - x coordinate of the chosen location
#' @param y               double - y coordinateof the chosen location
#' @param crs             projection definition to be converted from
#' @return xy             matrix with latlong coordinates
.sits_proj_to_latlong <- function(x, y, crs) {


    st_point <- sf::st_point(c(x, y))
    xy <- sf::st_sfc(st_point, crs = crs)

    obj.sf <- sf::st_transform(xy, crs = "+init=epsg:4326")

    latlong <- sf::st_coordinates(obj.sf)

    return(latlong)

}
#' @title Convert resolution from projection values to lat/long
#' @name .sits_convert_resolution
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Transform a latitude and longitude coordinate to a XY projection coordinate
#'
#' @param coverage        metadata about a coverage
#' @return res            matrix with resolution in WGS84 coordinates
.sits_convert_resolution <- function(coverage) {

    # create a vector to store the result
    res <- vector()
    names[res] <- c("xres", "yres")

    # set the minimum and maximum coordinates
    xy1 <- sf::st_point(c(coverage$xmin, coverage$ymin))
    xy2 <- sf::st_point(c(coverage$xmax, coverage$ymax))

    xymin <- sf::st_sfc(xy1, crs = coverage$crs)
    xymax <- sf::st_sfc(xy2, crs = coverage$crs)

    # get the bounding box in lat/long
    llmin <- sf::st_coordinates(sf::st_transform(xymin, crs = "+init=epsg:4326"))
    llmax <- sf::st_coordinates(sf::st_transform(xymax, crs = "+init=epsg:4326"))

    res["xres"] <- (llmax["x"] - llmin["x"])/coverage$ncols
    res["yres"] <- (llmax["y"] - llmin["y"])/coverage$nrows

    return(res)

}
#' @title Tests if an XY position is inside a ST Raster Brick
#' @name .sits_XY_inside_raster
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description This function compares an XY position to the extent of a RasterBrick
#'              described by a raster metadata tibble, and return TRUE if the point is
#'              inside the extent of the RasterBrick object.
#'
#' @param xy         XY extent compatible with the R raster package
#' @param raster.tb  Tibble with metadata information about a raster data set
#' @return bool      TRUE if XY is inside the raster extent, FALSE otherwise
#'
.sits_XY_inside_raster <- function(xy, raster.tb){

    if (xy[1,"X"] < raster.tb[1,]$xmin) return(FALSE)
    if (xy[1,"X"] > raster.tb[1,]$xmax) return(FALSE)
    if (xy[1,"Y"] < raster.tb[1,]$ymin) return(FALSE)
    if (xy[1,"Y"] > raster.tb[1,]$ymax) return(FALSE)
    return(TRUE)
}



#' @title Implement a binary search to find the nearest date
#' @name .sits_binary_search
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Performs a binary search in a ordered set of integer values and
#'              returns the values closest to a reference
#'
#' @param values     a vector of ordered integers
#' @param val        a reference value
#' @return nearest   the input value closest to the reference one
.sits_binary_search <- function(values, val){
    if (length(values) == 1) return(values[1])
    if (length(values) == 2) {
        if ((values[1] - val) < (values[2] - val))
            return(values[1])
        else
            return(values[2])
    }
    mid <- as.integer(length(values)/2)
    if (val < values[mid])
        .sits_binary_search(values[1:mid], val)
    else
        .sits_binary_search(values[(mid + 1):length(values)], val)

}



