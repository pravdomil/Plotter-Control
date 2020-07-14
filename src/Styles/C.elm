module Styles.C exposing (..)

{-| To get more CSS class safety, we extract all classes from our stylesheets.
To get fresh classes run following script in the browser.

```js
function getCssClasses() {
  const a = [...document.styleSheets]
    .map((b) => [...b.cssRules])
    .flat()
    .map((b) => b.selectorText)
    .filter((b) => b)
    .map((b) => b.split(","))
    .flat()
    .map((b) => b.trim())
    .filter((b) => b.match(/^\./))
    .map((b) => b.replace(/^\.([a-zA-Z0-9_-]*).*$/, "$1"))
    .map((b) => `${b.replace(/-./g, (c) => c.substr(1).toUpperCase())} = class ${JSON.stringify(b)}`)
  return [...new Set(a).keys()].join("\n")
}
document.write(getCssClasses().replace(/\\n/g, "<br>"))
```

-}

import Html.Attributes exposing (class)


h1 =
    class "h1"


h2 =
    class "h2"


h3 =
    class "h3"


h4 =
    class "h4"


h5 =
    class "h5"


h6 =
    class "h6"


small =
    class "small"


mark =
    class "mark"


lead =
    class "lead"


display1 =
    class "display-1"


display2 =
    class "display-2"


display3 =
    class "display-3"


display4 =
    class "display-4"


display5 =
    class "display-5"


display6 =
    class "display-6"


listUnstyled =
    class "list-unstyled"


listInline =
    class "list-inline"


listInlineItem =
    class "list-inline-item"


initialism =
    class "initialism"


blockquote =
    class "blockquote"


blockquoteFooter =
    class "blockquote-footer"


imgFluid =
    class "img-fluid"


imgThumbnail =
    class "img-thumbnail"


figure =
    class "figure"


figureImg =
    class "figure-img"


figureCaption =
    class "figure-caption"


container =
    class "container"


containerFluid =
    class "container-fluid"


containerLg =
    class "container-lg"


containerMd =
    class "container-md"


containerSm =
    class "container-sm"


containerXl =
    class "container-xl"


containerXxl =
    class "container-xxl"


row =
    class "row"


col =
    class "col"


rowColsAuto =
    class "row-cols-auto"


rowCols1 =
    class "row-cols-1"


rowCols2 =
    class "row-cols-2"


rowCols3 =
    class "row-cols-3"


rowCols4 =
    class "row-cols-4"


rowCols5 =
    class "row-cols-5"


rowCols6 =
    class "row-cols-6"


colAuto =
    class "col-auto"


col1 =
    class "col-1"


col2 =
    class "col-2"


col3 =
    class "col-3"


col4 =
    class "col-4"


col5 =
    class "col-5"


col6 =
    class "col-6"


col7 =
    class "col-7"


col8 =
    class "col-8"


col9 =
    class "col-9"


col10 =
    class "col-10"


col11 =
    class "col-11"


col12 =
    class "col-12"


offset1 =
    class "offset-1"


offset2 =
    class "offset-2"


offset3 =
    class "offset-3"


offset4 =
    class "offset-4"


offset5 =
    class "offset-5"


offset6 =
    class "offset-6"


offset7 =
    class "offset-7"


offset8 =
    class "offset-8"


offset9 =
    class "offset-9"


offset10 =
    class "offset-10"


offset11 =
    class "offset-11"


g0 =
    class "g-0"


gx0 =
    class "gx-0"


gy0 =
    class "gy-0"


g1 =
    class "g-1"


gx1 =
    class "gx-1"


gy1 =
    class "gy-1"


g2 =
    class "g-2"


gx2 =
    class "gx-2"


gy2 =
    class "gy-2"


g3 =
    class "g-3"


gx3 =
    class "gx-3"


gy3 =
    class "gy-3"


g4 =
    class "g-4"


gx4 =
    class "gx-4"


gy4 =
    class "gy-4"


g5 =
    class "g-5"


gx5 =
    class "gx-5"


gy5 =
    class "gy-5"


table =
    class "table"


captionTop =
    class "caption-top"


tableSm =
    class "table-sm"


tableBordered =
    class "table-bordered"


tableBorderless =
    class "table-borderless"


tableStriped =
    class "table-striped"


tableActive =
    class "table-active"


tableHover =
    class "table-hover"


tablePrimary =
    class "table-primary"


tableSecondary =
    class "table-secondary"


tableSuccess =
    class "table-success"


tableInfo =
    class "table-info"


tableWarning =
    class "table-warning"


tableDanger =
    class "table-danger"


tableLight =
    class "table-light"


tableDark =
    class "table-dark"


tableResponsive =
    class "table-responsive"


formLabel =
    class "form-label"


colFormLabel =
    class "col-form-label"


colFormLabelLg =
    class "col-form-label-lg"


colFormLabelSm =
    class "col-form-label-sm"


formText =
    class "form-text"


formControl =
    class "form-control"


formControlPlaintext =
    class "form-control-plaintext"


formControlSm =
    class "form-control-sm"


formControlLg =
    class "form-control-lg"


formControlColor =
    class "form-control-color"


formSelect =
    class "form-select"


formSelectSm =
    class "form-select-sm"


formSelectLg =
    class "form-select-lg"


formCheck =
    class "form-check"


formCheckInput =
    class "form-check-input"


formSwitch =
    class "form-switch"


formCheckInline =
    class "form-check-inline"


btnCheck =
    class "btn-check"


formFile =
    class "form-file"


formFileInput =
    class "form-file-input"


formFileLabel =
    class "form-file-label"


formFileText =
    class "form-file-text"


formFileButton =
    class "form-file-button"


formFileSm =
    class "form-file-sm"


formFileLg =
    class "form-file-lg"


formRange =
    class "form-range"


inputGroup =
    class "input-group"


inputGroupText =
    class "input-group-text"


inputGroupLg =
    class "input-group-lg"


inputGroupSm =
    class "input-group-sm"


validFeedback =
    class "valid-feedback"


validTooltip =
    class "valid-tooltip"


isValid =
    class "is-valid"


wasValidated =
    class "was-validated"


invalidFeedback =
    class "invalid-feedback"


invalidTooltip =
    class "invalid-tooltip"


isInvalid =
    class "is-invalid"


btn =
    class "btn"


btnPrimary =
    class "btn-primary"


show =
    class "show"


btnSecondary =
    class "btn-secondary"


btnSuccess =
    class "btn-success"


btnInfo =
    class "btn-info"


btnWarning =
    class "btn-warning"


btnDanger =
    class "btn-danger"


btnLight =
    class "btn-light"


btnDark =
    class "btn-dark"


btnOutlinePrimary =
    class "btn-outline-primary"


btnOutlineSecondary =
    class "btn-outline-secondary"


btnOutlineSuccess =
    class "btn-outline-success"


btnOutlineInfo =
    class "btn-outline-info"


btnOutlineWarning =
    class "btn-outline-warning"


btnOutlineDanger =
    class "btn-outline-danger"


btnOutlineLight =
    class "btn-outline-light"


btnOutlineDark =
    class "btn-outline-dark"


btnLink =
    class "btn-link"


btnGroupLg =
    class "btn-group-lg"


btnLg =
    class "btn-lg"


btnGroupSm =
    class "btn-group-sm"


btnSm =
    class "btn-sm"


btnBlock =
    class "btn-block"


fade =
    class "fade"


collapse =
    class "collapse"


collapsing =
    class "collapsing"


dropdown =
    class "dropdown"


dropleft =
    class "dropleft"


dropright =
    class "dropright"


dropup =
    class "dropup"


dropdownToggle =
    class "dropdown-toggle"


dropdownMenu =
    class "dropdown-menu"


dropdownMenuLeft =
    class "dropdown-menu-left"


dropdownMenuRight =
    class "dropdown-menu-right"


dropdownDivider =
    class "dropdown-divider"


dropdownItem =
    class "dropdown-item"


dropdownHeader =
    class "dropdown-header"


dropdownItemText =
    class "dropdown-item-text"


btnGroup =
    class "btn-group"


btnGroupVertical =
    class "btn-group-vertical"


btnToolbar =
    class "btn-toolbar"


dropdownToggleSplit =
    class "dropdown-toggle-split"


nav =
    class "nav"


navLink =
    class "nav-link"


navTabs =
    class "nav-tabs"


navPills =
    class "nav-pills"


navFill =
    class "nav-fill"


navJustified =
    class "nav-justified"


tabContent =
    class "tab-content"


navbar =
    class "navbar"


navbarBrand =
    class "navbar-brand"


navbarNav =
    class "navbar-nav"


navbarText =
    class "navbar-text"


navbarCollapse =
    class "navbar-collapse"


navbarToggler =
    class "navbar-toggler"


navbarTogglerIcon =
    class "navbar-toggler-icon"


navbarExpand =
    class "navbar-expand"


navbarLight =
    class "navbar-light"


navbarDark =
    class "navbar-dark"


card =
    class "card"


cardBody =
    class "card-body"


cardTitle =
    class "card-title"


cardSubtitle =
    class "card-subtitle"


cardText =
    class "card-text"


cardLink =
    class "card-link"


cardHeader =
    class "card-header"


cardFooter =
    class "card-footer"


cardHeaderTabs =
    class "card-header-tabs"


cardHeaderPills =
    class "card-header-pills"


cardImgOverlay =
    class "card-img-overlay"


cardImg =
    class "card-img"


cardImgBottom =
    class "card-img-bottom"


cardImgTop =
    class "card-img-top"


cardGroup =
    class "card-group"


accordion =
    class "accordion"


breadcrumb =
    class "breadcrumb"


breadcrumbItem =
    class "breadcrumb-item"


pagination =
    class "pagination"


pageLink =
    class "page-link"


pageItem =
    class "page-item"


paginationLg =
    class "pagination-lg"


paginationSm =
    class "pagination-sm"


badge =
    class "badge"


alert =
    class "alert"


alertHeading =
    class "alert-heading"


alertLink =
    class "alert-link"


alertDismissible =
    class "alert-dismissible"


alertPrimary =
    class "alert-primary"


alertSecondary =
    class "alert-secondary"


alertSuccess =
    class "alert-success"


alertInfo =
    class "alert-info"


alertWarning =
    class "alert-warning"


alertDanger =
    class "alert-danger"


alertLight =
    class "alert-light"


alertDark =
    class "alert-dark"


progress =
    class "progress"


progressBar =
    class "progress-bar"


progressBarStriped =
    class "progress-bar-striped"


progressBarAnimated =
    class "progress-bar-animated"


listGroup =
    class "list-group"


listGroupItemAction =
    class "list-group-item-action"


listGroupItem =
    class "list-group-item"


listGroupHorizontal =
    class "list-group-horizontal"


listGroupFlush =
    class "list-group-flush"


listGroupItemPrimary =
    class "list-group-item-primary"


listGroupItemSecondary =
    class "list-group-item-secondary"


listGroupItemSuccess =
    class "list-group-item-success"


listGroupItemInfo =
    class "list-group-item-info"


listGroupItemWarning =
    class "list-group-item-warning"


listGroupItemDanger =
    class "list-group-item-danger"


listGroupItemLight =
    class "list-group-item-light"


listGroupItemDark =
    class "list-group-item-dark"


close =
    class "close"


toast =
    class "toast"


toastHeader =
    class "toast-header"


toastBody =
    class "toast-body"


modalOpen =
    class "modal-open"


modal =
    class "modal"


modalDialog =
    class "modal-dialog"


modalDialogScrollable =
    class "modal-dialog-scrollable"


modalDialogCentered =
    class "modal-dialog-centered"


modalContent =
    class "modal-content"


modalBackdrop =
    class "modal-backdrop"


modalHeader =
    class "modal-header"


modalTitle =
    class "modal-title"


modalBody =
    class "modal-body"


modalFooter =
    class "modal-footer"


modalScrollbarMeasure =
    class "modal-scrollbar-measure"


modalFullscreen =
    class "modal-fullscreen"


tooltip =
    class "tooltip"


bsTooltipAuto =
    class "bs-tooltip-auto"


bsTooltipTop =
    class "bs-tooltip-top"


bsTooltipRight =
    class "bs-tooltip-right"


bsTooltipBottom =
    class "bs-tooltip-bottom"


bsTooltipLeft =
    class "bs-tooltip-left"


tooltipInner =
    class "tooltip-inner"


popover =
    class "popover"


bsPopoverAuto =
    class "bs-popover-auto"


bsPopoverTop =
    class "bs-popover-top"


bsPopoverRight =
    class "bs-popover-right"


bsPopoverBottom =
    class "bs-popover-bottom"


bsPopoverLeft =
    class "bs-popover-left"


popoverHeader =
    class "popover-header"


popoverBody =
    class "popover-body"


carousel =
    class "carousel"


carouselInner =
    class "carousel-inner"


carouselItem =
    class "carousel-item"


carouselItemNext =
    class "carousel-item-next"


carouselItemPrev =
    class "carousel-item-prev"


active =
    class "active"


carouselFade =
    class "carousel-fade"


carouselControlNext =
    class "carousel-control-next"


carouselControlPrev =
    class "carousel-control-prev"


carouselControlNextIcon =
    class "carousel-control-next-icon"


carouselControlPrevIcon =
    class "carousel-control-prev-icon"


carouselIndicators =
    class "carousel-indicators"


carouselCaption =
    class "carousel-caption"


spinnerBorder =
    class "spinner-border"


spinnerBorderSm =
    class "spinner-border-sm"


spinnerGrow =
    class "spinner-grow"


spinnerGrowSm =
    class "spinner-grow-sm"


clearfix =
    class "clearfix"


linkPrimary =
    class "link-primary"


linkSecondary =
    class "link-secondary"


linkSuccess =
    class "link-success"


linkInfo =
    class "link-info"


linkWarning =
    class "link-warning"


linkDanger =
    class "link-danger"


linkLight =
    class "link-light"


linkDark =
    class "link-dark"


embedResponsive =
    class "embed-responsive"


embedResponsive21by9 =
    class "embed-responsive-21by9"


embedResponsive16by9 =
    class "embed-responsive-16by9"


embedResponsive4by3 =
    class "embed-responsive-4by3"


embedResponsive1by1 =
    class "embed-responsive-1by1"


fixedTop =
    class "fixed-top"


fixedBottom =
    class "fixed-bottom"


stickyTop =
    class "sticky-top"


srOnly =
    class "sr-only"


srOnlyFocusable =
    class "sr-only-focusable"


stretchedLink =
    class "stretched-link"


textTruncate =
    class "text-truncate"


alignBaseline =
    class "align-baseline"


alignTop =
    class "align-top"


alignMiddle =
    class "align-middle"


alignBottom =
    class "align-bottom"


alignTextBottom =
    class "align-text-bottom"


alignTextTop =
    class "align-text-top"


floatLeft =
    class "float-left"


floatRight =
    class "float-right"


floatNone =
    class "float-none"


overflowAuto =
    class "overflow-auto"


overflowHidden =
    class "overflow-hidden"


dNone =
    class "d-none"


dInline =
    class "d-inline"


dInlineBlock =
    class "d-inline-block"


dBlock =
    class "d-block"


dTable =
    class "d-table"


dTableRow =
    class "d-table-row"


dTableCell =
    class "d-table-cell"


dFlex =
    class "d-flex"


dInlineFlex =
    class "d-inline-flex"


shadow =
    class "shadow"


shadowSm =
    class "shadow-sm"


shadowLg =
    class "shadow-lg"


shadowNone =
    class "shadow-none"


positionStatic =
    class "position-static"


positionRelative =
    class "position-relative"


positionAbsolute =
    class "position-absolute"


positionFixed =
    class "position-fixed"


positionSticky =
    class "position-sticky"


border =
    class "border"


border0 =
    class "border-0"


borderTop =
    class "border-top"


borderTop0 =
    class "border-top-0"


borderRight =
    class "border-right"


borderRight0 =
    class "border-right-0"


borderBottom =
    class "border-bottom"


borderBottom0 =
    class "border-bottom-0"


borderLeft =
    class "border-left"


borderLeft0 =
    class "border-left-0"


borderPrimary =
    class "border-primary"


borderSecondary =
    class "border-secondary"


borderSuccess =
    class "border-success"


borderInfo =
    class "border-info"


borderWarning =
    class "border-warning"


borderDanger =
    class "border-danger"


borderLight =
    class "border-light"


borderDark =
    class "border-dark"


borderWhite =
    class "border-white"


w25 =
    class "w-25"


w50 =
    class "w-50"


w75 =
    class "w-75"


w100 =
    class "w-100"


wAuto =
    class "w-auto"


mw100 =
    class "mw-100"


vw100 =
    class "vw-100"


minVw100 =
    class "min-vw-100"


h25 =
    class "h-25"


h50 =
    class "h-50"


h75 =
    class "h-75"


h100 =
    class "h-100"


hAuto =
    class "h-auto"


mh100 =
    class "mh-100"


vh100 =
    class "vh-100"


minVh100 =
    class "min-vh-100"


flexFill =
    class "flex-fill"


flexRow =
    class "flex-row"


flexColumn =
    class "flex-column"


flexRowReverse =
    class "flex-row-reverse"


flexColumnReverse =
    class "flex-column-reverse"


flexGrow0 =
    class "flex-grow-0"


flexGrow1 =
    class "flex-grow-1"


flexShrink0 =
    class "flex-shrink-0"


flexShrink1 =
    class "flex-shrink-1"


flexWrap =
    class "flex-wrap"


flexNowrap =
    class "flex-nowrap"


flexWrapReverse =
    class "flex-wrap-reverse"


justifyContentStart =
    class "justify-content-start"


justifyContentEnd =
    class "justify-content-end"


justifyContentCenter =
    class "justify-content-center"


justifyContentBetween =
    class "justify-content-between"


justifyContentAround =
    class "justify-content-around"


justifyContentEvenly =
    class "justify-content-evenly"


alignItemsStart =
    class "align-items-start"


alignItemsEnd =
    class "align-items-end"


alignItemsCenter =
    class "align-items-center"


alignItemsBaseline =
    class "align-items-baseline"


alignItemsStretch =
    class "align-items-stretch"


alignContentStart =
    class "align-content-start"


alignContentEnd =
    class "align-content-end"


alignContentCenter =
    class "align-content-center"


alignContentBetween =
    class "align-content-between"


alignContentAround =
    class "align-content-around"


alignContentStretch =
    class "align-content-stretch"


alignSelfAuto =
    class "align-self-auto"


alignSelfStart =
    class "align-self-start"


alignSelfEnd =
    class "align-self-end"


alignSelfCenter =
    class "align-self-center"


alignSelfBaseline =
    class "align-self-baseline"


alignSelfStretch =
    class "align-self-stretch"


orderFirst =
    class "order-first"


order0 =
    class "order-0"


order1 =
    class "order-1"


order2 =
    class "order-2"


order3 =
    class "order-3"


order4 =
    class "order-4"


order5 =
    class "order-5"


orderLast =
    class "order-last"


m0 =
    class "m-0"


m1 =
    class "m-1"


m2 =
    class "m-2"


m3 =
    class "m-3"


m4 =
    class "m-4"


m5 =
    class "m-5"


mAuto =
    class "m-auto"


mx0 =
    class "mx-0"


mx1 =
    class "mx-1"


mx2 =
    class "mx-2"


mx3 =
    class "mx-3"


mx4 =
    class "mx-4"


mx5 =
    class "mx-5"


mxAuto =
    class "mx-auto"


my0 =
    class "my-0"


my1 =
    class "my-1"


my2 =
    class "my-2"


my3 =
    class "my-3"


my4 =
    class "my-4"


my5 =
    class "my-5"


myAuto =
    class "my-auto"


mt0 =
    class "mt-0"


mt1 =
    class "mt-1"


mt2 =
    class "mt-2"


mt3 =
    class "mt-3"


mt4 =
    class "mt-4"


mt5 =
    class "mt-5"


mtAuto =
    class "mt-auto"


mr0 =
    class "mr-0"


mr1 =
    class "mr-1"


mr2 =
    class "mr-2"


mr3 =
    class "mr-3"


mr4 =
    class "mr-4"


mr5 =
    class "mr-5"


mrAuto =
    class "mr-auto"


mb0 =
    class "mb-0"


mb1 =
    class "mb-1"


mb2 =
    class "mb-2"


mb3 =
    class "mb-3"


mb4 =
    class "mb-4"


mb5 =
    class "mb-5"


mbAuto =
    class "mb-auto"


ml0 =
    class "ml-0"


ml1 =
    class "ml-1"


ml2 =
    class "ml-2"


ml3 =
    class "ml-3"


ml4 =
    class "ml-4"


ml5 =
    class "ml-5"


mlAuto =
    class "ml-auto"


p0 =
    class "p-0"


p1 =
    class "p-1"


p2 =
    class "p-2"


p3 =
    class "p-3"


p4 =
    class "p-4"


p5 =
    class "p-5"


px0 =
    class "px-0"


px1 =
    class "px-1"


px2 =
    class "px-2"


px3 =
    class "px-3"


px4 =
    class "px-4"


px5 =
    class "px-5"


py0 =
    class "py-0"


py1 =
    class "py-1"


py2 =
    class "py-2"


py3 =
    class "py-3"


py4 =
    class "py-4"


py5 =
    class "py-5"


pt0 =
    class "pt-0"


pt1 =
    class "pt-1"


pt2 =
    class "pt-2"


pt3 =
    class "pt-3"


pt4 =
    class "pt-4"


pt5 =
    class "pt-5"


pr0 =
    class "pr-0"


pr1 =
    class "pr-1"


pr2 =
    class "pr-2"


pr3 =
    class "pr-3"


pr4 =
    class "pr-4"


pr5 =
    class "pr-5"


pb0 =
    class "pb-0"


pb1 =
    class "pb-1"


pb2 =
    class "pb-2"


pb3 =
    class "pb-3"


pb4 =
    class "pb-4"


pb5 =
    class "pb-5"


pl0 =
    class "pl-0"


pl1 =
    class "pl-1"


pl2 =
    class "pl-2"


pl3 =
    class "pl-3"


pl4 =
    class "pl-4"


pl5 =
    class "pl-5"


fontWeightLight =
    class "font-weight-light"


fontWeightLighter =
    class "font-weight-lighter"


fontWeightNormal =
    class "font-weight-normal"


fontWeightBold =
    class "font-weight-bold"


fontWeightBolder =
    class "font-weight-bolder"


textLowercase =
    class "text-lowercase"


textUppercase =
    class "text-uppercase"


textCapitalize =
    class "text-capitalize"


textLeft =
    class "text-left"


textRight =
    class "text-right"


textCenter =
    class "text-center"


textPrimary =
    class "text-primary"


textSecondary =
    class "text-secondary"


textSuccess =
    class "text-success"


textInfo =
    class "text-info"


textWarning =
    class "text-warning"


textDanger =
    class "text-danger"


textLight =
    class "text-light"


textDark =
    class "text-dark"


textWhite =
    class "text-white"


textBody =
    class "text-body"


textMuted =
    class "text-muted"


textBlack50 =
    class "text-black-50"


textWhite50 =
    class "text-white-50"


textReset =
    class "text-reset"


lh1 =
    class "lh-1"


lhSm =
    class "lh-sm"


lhBase =
    class "lh-base"


lhLg =
    class "lh-lg"


bgPrimary =
    class "bg-primary"


bgSecondary =
    class "bg-secondary"


bgSuccess =
    class "bg-success"


bgInfo =
    class "bg-info"


bgWarning =
    class "bg-warning"


bgDanger =
    class "bg-danger"


bgLight =
    class "bg-light"


bgDark =
    class "bg-dark"


bgBody =
    class "bg-body"


bgWhite =
    class "bg-white"


bgTransparent =
    class "bg-transparent"


bgGradient =
    class "bg-gradient"


textWrap =
    class "text-wrap"


textNowrap =
    class "text-nowrap"


textDecorationNone =
    class "text-decoration-none"


textDecorationUnderline =
    class "text-decoration-underline"


textDecorationLineThrough =
    class "text-decoration-line-through"


fontItalic =
    class "font-italic"


fontNormal =
    class "font-normal"


textBreak =
    class "text-break"


fontMonospace =
    class "font-monospace"


userSelectAll =
    class "user-select-all"


userSelectAuto =
    class "user-select-auto"


userSelectNone =
    class "user-select-none"


peNone =
    class "pe-none"


peAuto =
    class "pe-auto"


rounded =
    class "rounded"


roundedSm =
    class "rounded-sm"


roundedLg =
    class "rounded-lg"


roundedCircle =
    class "rounded-circle"


roundedPill =
    class "rounded-pill"


rounded0 =
    class "rounded-0"


roundedTop =
    class "rounded-top"


roundedRight =
    class "rounded-right"


roundedBottom =
    class "rounded-bottom"


roundedLeft =
    class "rounded-left"


visible =
    class "visible"


invisible =
    class "invisible"
