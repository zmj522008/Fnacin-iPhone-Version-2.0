//
//  NSString+removeTags.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+removeTags.h"


@implementation NSString (NSString_removeTags)
static NSDictionary* entityDic;
+ (NSString*) stringWithoutTags:(NSString*)source
{
    if (entityDic == nil) {
      entityDic = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"é", @"eacute",
                   @"\"", @"quot",
                   @"&", @"amp",
                   @"'", @"apos",
                   @"<", @"lt",
                   @">", @"gt",
                   @" ", @"nbsp",
                   @"¡", @"iexcl",
                   @"¢", @"cent",
                   @"£", @"pound",
                   @"¤", @"curren",
                   @"¥", @"yen",
                   @"¦", @"brvbar",
                   @"§", @"sect",
                   @"¨", @"uml",
                   @"©", @"copy",
                   @"ª", @"ordf",
                   @"«", @"laquo",
                   @"¬", @"not",
                   @" ", @"shy",
                   @"®", @"reg",
                   @"¯", @"macr",
                   @"°", @"deg",
                   @"±", @"plusmn",
                   @"²", @"sup2",
                   @"³", @"sup3",
                   @"´", @"acute",
                   @"µ", @"micro",
                   @"¶", @"para",
                   @"·", @"middot",
                   @"¸", @"cedil",
                   @"¹", @"sup1",
                   @"º", @"ordm",
                   @"»", @"raquo",
                   @"¼", @"frac14",
                   @"½", @"frac12",
                   @"¾", @"frac34",
                   @"¿", @"iquest",
                   @"À", @"Agrave",
                   @"Á", @"Aacute",
                   @"Â", @"Acirc",
                   @"Ã", @"Atilde",
                   @"Ä", @"Auml",
                   @"Å", @"Aring",
                   @"Æ", @"AElig",
                   @"Ç", @"Ccedil",
                   @"È", @"Egrave",
                   @"É", @"Eacute",
                   @"Ê", @"Ecirc",
                   @"Ë", @"Euml",
                   @"Ì", @"Igrave",
                   @"Í", @"Iacute",
                   @"Î", @"Icirc",
                   @"Ï", @"Iuml",
                   @"Ð", @"ETH",
                   @"Ñ", @"Ntilde",
                   @"Ò", @"Ograve",
                   @"Ó", @"Oacute",
                   @"Ô", @"Ocirc",
                   @"Õ", @"Otilde",
                   @"Ö", @"Ouml",
                   @"×", @"times",
                   @"Ø", @"Oslash",
                   @"Ù", @"Ugrave",
                   @"Ú", @"Uacute",
                   @"Û", @"Ucirc",
                   @"Ü", @"Uuml",
                   @"Ý", @"Yacute",
                   @"Þ", @"THORN",
                   @"ß", @"szlig",
                   @"à", @"agrave",
                   @"á", @"aacute",
                   @"â", @"acirc",
                   @"ã", @"atilde",
                   @"ä", @"auml",
                   @"å", @"aring",
                   @"æ", @"aelig",
                   @"ç", @"ccedil",
                   @"è", @"egrave",
                   @"é", @"eacute",
                   @"ê", @"ecirc",
                   @"ë", @"euml",
                   @"ì", @"igrave",
                   @"í", @"iacute",
                   @"î", @"icirc",
                   @"ï", @"iuml",
                   @"ð", @"eth",
                   @"ñ", @"ntilde",
                   @"ò", @"ograve",
                   @"ó", @"oacute",
                   @"ô", @"ocirc",
                   @"õ", @"otilde",
                   @"ö", @"ouml",
                   @"÷", @"divide",
                   @"ø", @"oslash",
                   @"ù", @"ugrave",
                   @"ú", @"uacute",
                   @"û", @"ucirc",
                   @"ü", @"uuml",
                   @"ý", @"yacute",
                   @"þ", @"thorn",
                   @"ÿ", @"yuml",
                   @"Œ", @"OElig",
                   @"œ", @"oelig",
                   @"Š", @"Scaron",
                   @"š", @"scaron",
                   @"Ÿ", @"Yuml",
                   @"ƒ", @"fnof",
                   @"ˆ", @"circ",
                   @"˜", @"tilde",
                   @"Α", @"Alpha",
                   @"Β", @"Beta",
                   @"Γ", @"Gamma",
                   @"Δ", @"Delta",
                   @"Ε", @"Epsilon",
                   @"Ζ", @"Zeta",
                   @"Η", @"Eta",
                   @"Θ", @"Theta",
                   @"Ι", @"Iota",
                   @"Κ", @"Kappa",
                   @"Λ", @"Lambda",
                   @"Μ", @"Mu",
                   @"Ν", @"Nu",
                   @"Ξ", @"Xi",
                   @"Ο", @"Omicron",
                   @"Π", @"Pi",
                   @"Ρ", @"Rho",
                   @"Σ", @"Sigma",
                   @"Τ", @"Tau",
                   @"Υ", @"Upsilon",
                   @"Φ", @"Phi",
                   @"Χ", @"Chi",
                   @"Ψ", @"Psi",
                   @"Ω", @"Omega",
                   @"α", @"alpha",
                   @"β", @"beta",
                   @"γ", @"gamma",
                   @"δ", @"delta",
                   @"ε", @"epsilon",
                   @"ζ", @"zeta",
                   @"η", @"eta",
                   @"θ", @"theta",
                   @"ι", @"iota",
                   @"κ", @"kappa",
                   @"λ", @"lambda",
                   @"μ", @"mu",
                   @"ν", @"nu",
                   @"ξ", @"xi",
                   @"ο", @"omicron",
                   @"π", @"pi",
                   @"ρ", @"rho",
                   @"ς", @"sigmaf",
                   @"σ", @"sigma",
                   @"τ", @"tau",
                   @"υ", @"upsilon",
                   @"φ", @"phi",
                   @"χ", @"chi",
                   @"ψ", @"psi",
                   @"ω", @"omega",
                   @"ϑ", @"thetasym",
                   @"ϒ", @"upsih",
                   @"ϖ", @"piv",
                   @" ", @"ensp",
                   @" ", @"emsp",
                   @" ", @"thinsp",
                   @" ", @"zwnj",
                   @" ", @"zwj",
                   @" ", @"lrm",
                   @" ", @"rlm",
                   @"–", @"ndash",
                   @"—", @"mdash",
                   @"‘", @"lsquo",
                   @"’", @"rsquo",
                   @"‚", @"sbquo",
                   @"“", @"ldquo",
                   @"”", @"rdquo",
                   @"„", @"bdquo",
                   @"†", @"dagger",
                   @"‡", @"Dagger",
                   @"•", @"bull",
                   @"…", @"hellip",
                   @"‰", @"permil",
                   @"′", @"prime",
                   @"″", @"Prime",
                   @"‹", @"lsaquo",
                   @"›", @"rsaquo",
                   @"‾", @"oline",
                   @"⁄", @"frasl",
                   @"€", @"euro",
                   @"ℑ", @"image",
                   @"℘", @"weierp",
                   @"ℜ", @"real",
                   @"™", @"trade",
                   @"ℵ", @"alefsym",
                   @"←", @"larr",
                   @"↑", @"uarr",
                   @"→", @"rarr",
                   @"↓", @"darr",
                   @"↔", @"harr",
                   @"↵", @"crarr",
                   @"⇐", @"lArr",
                   @"⇑", @"uArr",
                   @"⇒", @"rArr",
                   @"⇓", @"dArr",
                   @"⇔", @"hArr",
                   @"∀", @"forall",
                   @"∂", @"part",
                   @"∃", @"exist",
                   @"∅", @"empty",
                   @"∇", @"nabla",
                   @"∈", @"isin",
                   @"∉", @"notin",
                   @"∋", @"ni",
                   @"∏", @"prod",
                   @"∑", @"sum",
                   @"−", @"minus",
                   @"∗", @"lowast",
                   @"√", @"radic",
                   @"∝", @"prop",
                   @"∞", @"infin",
                   @"∠", @"ang",
                   @"∧", @"and",
                   @"∨", @"or",
                   @"∩", @"cap",
                   @"∪", @"cup",
                   @"∫", @"int",
                   @"∴", @"there4",
                   @"∼", @"sim",
                   @"≅", @"cong",
                   @"≈", @"asymp",
                   @"≠", @"ne",
                   @"≡", @"equiv",
                   @"≤", @"le",
                   @"≥", @"ge",
                   @"⊂", @"sub",
                   @"⊃", @"sup",
                   @"⊄", @"nsub",
                   @"⊆", @"sube",
                   @"⊇", @"supe",
                   @"⊕", @"oplus",
                   @"⊗", @"otimes",
                   @"⊥", @"perp",
                   @"⋅", @"sdot",
                   @"⌈", @"lceil",
                   @"⌉", @"rceil",
                   @"⌊", @"lfloor",
                   @"⌋", @"rfloor",
                   @"〈", @"lang",
                   @"〉", @"rang",
                   @"◊", @"loz",
                   @"♠", @"spades",
                   @"♣", @"clubs",
                   @"♥", @"hearts",
                   @"♦", @"diams",
                   nil];
        [entityDic retain];
    }
    NSMutableString* text = [NSMutableString stringWithCapacity:source.length];
    int entityStart = -1;
    BOOL inTag = NO;
    for (int i = 0; i < source.length; i++) {
        unichar ch = [source characterAtIndex:i];
        if (ch == '&') {
            entityStart = i;
        } else if (ch == '<') {
            inTag = YES;
        }
        if (entityStart != -1 || inTag) {
            if (ch == ';') {
                NSString* entity = [source substringWithRange:NSMakeRange(entityStart + 1, i - entityStart - 1)];
                NSString* value = [entityDic objectForKey:entity];
                if (value == nil) {
                    value = @"_";
                } 
                [text appendString:value];
                entityStart = -1;
            } else if (ch == '>') {
                inTag = NO;
            }
        } else {
            [text appendFormat:@"%c", ch];
        }
    }
    return text;
}

@end
