module Ui.Base exposing (..)

import Element
import Element.Background
import Element.Border
import Element.Events
import Element.Font
import Element.Input
import Element.Keyed
import Element.Lazy
import Element.Region
import Ui.Style as S


rem a =
    round (S.rem * a)


rem_ a =
    S.rem * a



--


type alias Attr decorative msg =
    Element.Attr decorative msg


type alias Attribute msg =
    Element.Attribute msg


type alias Color =
    Element.Color


type alias Column record msg =
    Element.Column record msg


type alias Decoration =
    Element.Decoration


type alias Device =
    Element.Device


type alias Element msg =
    Element.Element msg


type alias FocusStyle =
    Element.FocusStyle


type alias IndexedColumn record msg =
    Element.IndexedColumn record msg


type alias Length =
    Element.Length


type alias Option =
    Element.Option


above =
    Element.above


alignBottom =
    Element.alignBottom


alignLeft =
    Element.alignLeft


alignRight =
    Element.alignRight


alignTop =
    Element.alignTop


alpha =
    Element.alpha


behindContent =
    Element.behindContent


below =
    Element.below


centerX =
    Element.centerX


centerY =
    Element.centerY


classifyDevice =
    Element.classifyDevice


clip =
    Element.clip


clipX =
    Element.clipX


clipY =
    Element.clipY


column =
    Element.column


download =
    Element.download


downloadAs =
    Element.downloadAs


el =
    Element.el


explain =
    Element.explain


fill =
    Element.fill


fillPortion =
    Element.fillPortion


focusStyle =
    Element.focusStyle


focused =
    Element.focused


forceHover =
    Element.forceHover


fromRgb =
    Element.fromRgb


fromRgb255 =
    Element.fromRgb255


height =
    Element.height


html =
    Element.html


htmlAttribute =
    Element.htmlAttribute


image =
    Element.image


inFront =
    Element.inFront


indexedTable =
    Element.indexedTable


layout =
    Element.layout


layoutWith =
    Element.layoutWith


link =
    Element.link


map =
    Element.map


mapAttribute =
    Element.mapAttribute


maximum =
    Element.maximum


minimum =
    Element.minimum


modular =
    Element.modular


mouseDown =
    Element.mouseDown


mouseOver =
    Element.mouseOver


moveDown =
    Element.moveDown


moveLeft =
    Element.moveLeft


moveRight =
    Element.moveRight


moveUp =
    Element.moveUp


newTabLink =
    Element.newTabLink


noHover =
    Element.noHover


noStaticStyleSheet =
    Element.noStaticStyleSheet


none =
    Element.none


onLeft =
    Element.onLeft


onRight =
    Element.onRight


padding =
    Element.padding


paddingEach minX maxX minY maxY =
    Element.paddingEach { left = minX, right = maxX, top = minY, bottom = maxY }


paddingXY =
    Element.paddingXY


paragraph =
    Element.paragraph


pointer =
    Element.pointer


px =
    Element.px


rgb =
    Element.rgb


rgb255 =
    Element.rgb255


rgba =
    Element.rgba


rgba255 =
    Element.rgba255


rotate =
    Element.rotate


row =
    Element.row


scale =
    Element.scale


scrollbarX =
    Element.scrollbarX


scrollbarY =
    Element.scrollbarY


scrollbars =
    Element.scrollbars


shrink =
    Element.shrink


spaceEvenly =
    Element.spaceEvenly


spacing =
    Element.spacing


spacingXY =
    Element.spacingXY


table =
    Element.table


text =
    Element.text


textColumn =
    Element.textColumn


toRgb =
    Element.toRgb


transparent =
    Element.transparent


width =
    Element.width


wrappedRow =
    Element.wrappedRow



--


bgColor =
    Element.Background.color


bgGradient =
    Element.Background.gradient


bgImage =
    Element.Background.image


bgTiled =
    Element.Background.tiled


bgTiledX =
    Element.Background.tiledX


bgTiledY =
    Element.Background.tiledY


bgUncropped =
    Element.Background.uncropped



--


borderColor =
    Element.Border.color


borderDashed =
    Element.Border.dashed


borderDotted =
    Element.Border.dotted


borderGlow =
    Element.Border.glow


borderInnerGlow =
    Element.Border.innerGlow


borderInnerShadow =
    Element.Border.innerShadow


borderRoundEach topLeft topRight bottomLeft bottomRight =
    Element.Border.roundEach { topLeft = topLeft, topRight = topRight, bottomLeft = bottomLeft, bottomRight = bottomRight }


borderRounded =
    Element.Border.rounded


borderShadow =
    Element.Border.shadow


borderSolid =
    Element.Border.solid


borderWidth =
    Element.Border.width


borderWidthEach minX maxX minY maxY =
    Element.Border.widthEach { left = minX, right = maxX, top = minY, bottom = maxY }


borderWidthXY =
    Element.Border.widthXY



--


onClick =
    Element.Events.onClick


onDoubleClick =
    Element.Events.onDoubleClick


onFocus =
    Element.Events.onFocus


onLoseFocus =
    Element.Events.onLoseFocus


onMouseDown =
    Element.Events.onMouseDown


onMouseEnter =
    Element.Events.onMouseEnter


onMouseLeave =
    Element.Events.onMouseLeave


onMouseMove =
    Element.Events.onMouseMove


onMouseUp =
    Element.Events.onMouseUp



--


type alias Font =
    Element.Font.Font


type alias Variant =
    Element.Font.Variant


fontAlignLeft =
    Element.Font.alignLeft


fontAlignRight =
    Element.Font.alignRight


fontBold =
    Element.Font.bold


fontCenter =
    Element.Font.center


fontColor =
    Element.Font.color


fontDiagonalFractions =
    Element.Font.diagonalFractions


fontExternal =
    Element.Font.external


fontExtraBold =
    Element.Font.extraBold


fontExtraLight =
    Element.Font.extraLight


fontFamily =
    Element.Font.family


fontFeature =
    Element.Font.feature


fontGlow =
    Element.Font.glow


fontHairline =
    Element.Font.hairline


fontHeavy =
    Element.Font.heavy


fontIndexed =
    Element.Font.indexed


fontItalic =
    Element.Font.italic


fontJustify =
    Element.Font.justify


fontLetterSpacing =
    Element.Font.letterSpacing


fontLigatures =
    Element.Font.ligatures


fontLight =
    Element.Font.light


fontMedium =
    Element.Font.medium


fontMonospace =
    Element.Font.monospace


fontOrdinal =
    Element.Font.ordinal


fontRegular =
    Element.Font.regular


fontSansSerif =
    Element.Font.sansSerif


fontSemiBold =
    Element.Font.semiBold


fontSerif =
    Element.Font.serif


fontShadow =
    Element.Font.shadow


fontSize =
    Element.Font.size


fontSlashedZero =
    Element.Font.slashedZero


fontSmallCaps =
    Element.Font.smallCaps


fontStackedFractions =
    Element.Font.stackedFractions


fontStrike =
    Element.Font.strike


fontSwash =
    Element.Font.swash


fontTabularNumbers =
    Element.Font.tabularNumbers


fontTypeface =
    Element.Font.typeface


fontUnderline =
    Element.Font.underline


fontUnitalicized =
    Element.Font.unitalicized


fontVariant =
    Element.Font.variant


fontVariantList =
    Element.Font.variantList


fontWordSpacing =
    Element.Font.wordSpacing



--


inputButton =
    Element.Input.button


inputCheckbox =
    Element.Input.checkbox


inputCurrentPassword =
    Element.Input.currentPassword


inputDefaultCheckbox =
    Element.Input.defaultCheckbox


inputDefaultThumb =
    Element.Input.defaultThumb


inputEmail =
    Element.Input.email


inputFocusedOnLoad =
    Element.Input.focusedOnLoad


inputLabelAbove =
    Element.Input.labelAbove


inputLabelBelow =
    Element.Input.labelBelow


inputLabelHidden =
    Element.Input.labelHidden


inputLabelLeft =
    Element.Input.labelLeft


inputLabelRight =
    Element.Input.labelRight


inputMultiline =
    Element.Input.multiline


inputNewPassword =
    Element.Input.newPassword


inputOption =
    Element.Input.option


inputOptionWith =
    Element.Input.optionWith


inputPlaceholder =
    Element.Input.placeholder


inputRadio =
    Element.Input.radio


inputRadioRow =
    Element.Input.radioRow


inputSearch =
    Element.Input.search


inputSlider =
    Element.Input.slider


inputSpellChecked =
    Element.Input.spellChecked


inputText =
    Element.Input.text


inputThumb =
    Element.Input.thumb


inputUsername =
    Element.Input.username



--


keyedColumn =
    Element.Keyed.column


keyedEl =
    Element.Keyed.el


keyedRow =
    Element.Keyed.row



--


lazy =
    Element.Lazy.lazy


lazy2 =
    Element.Lazy.lazy2


lazy3 =
    Element.Lazy.lazy3


lazy4 =
    Element.Lazy.lazy4


lazy5 =
    Element.Lazy.lazy5



--


regionAnnounce =
    Element.Region.announce


regionAnnounceUrgently =
    Element.Region.announceUrgently


regionAside =
    Element.Region.aside


regionDescription =
    Element.Region.description


regionFooter =
    Element.Region.footer


regionHeading =
    Element.Region.heading


regionMainContent =
    Element.Region.mainContent


regionNavigation =
    Element.Region.navigation
