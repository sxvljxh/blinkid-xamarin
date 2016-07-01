//
//  BlinkID.m
//  MicroBlink
//
//  Created by Jura on 24/02/16.
//  Copyright © 2016 MicroBlink. All rights reserved.
//

#import "BlinkID.h"

#import <MicroBlink/MicroBlink.h>

@interface BlinkID () <PPScanningDelegate>

@property (nonatomic) PPCameraType cameraType;

@property (nonatomic) NSMutableArray<PPRecognizerSettings*> *recognizers;

@property (nonatomic) NSMutableArray<PPOcrParserFactory*> *parsers;

@property (nonatomic) NSMutableArray<NSString*> *parserNames;

@end

@implementation BlinkID

- (instancetype)init {
    if (self = [super init]) {
        _recognizers = [NSMutableArray<PPRecognizerSettings*> array];
        _parsers = [NSMutableArray<PPOcrParserFactory*> array];
        _parserNames = [NSMutableArray<NSString*> array];
    }
    return self;
}

+ (instancetype)instance {
    static BlinkID *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BlinkID alloc] init];
    });
    return sharedInstance;
}

- (void)scan:(BOOL)isFrontCamera {
    
    if (!isFrontCamera) {
        self.cameraType = PPCameraTypeBack;
    } else {
        self.cameraType = PPCameraTypeFront;
    }

    /** Instantiate the scanning coordinator */
    NSError *error;
    PPCameraCoordinator *coordinator = [self coordinatorWithError:&error];

    /** If scanning isn't supported, present an error */
    if (coordinator == nil) {
        NSString *messageString = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Warning"
                                    message:messageString
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];

        return;
    }

    /** Allocate and present the scanning view controller */
    UIViewController<PPScanningViewController>* scanningViewController = [PPViewControllerFactory cameraViewControllerWithDelegate:self coordinator:coordinator error:nil];

    // allow rotation if VC is displayed as a modal view controller
    scanningViewController.autorotate = YES;
    scanningViewController.supportedOrientations = UIInterfaceOrientationMaskAll;
    
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:scanningViewController animated:YES completion:nil];
}

#pragma mark - PPScanDelegate

- (void)scanningViewControllerUnauthorizedCamera:(UIViewController<PPScanningViewController> *)scanningViewController {
    // Add any logic which handles UI when app user doesn't allow usage of the phone's camera
}

- (void)scanningViewController:(UIViewController<PPScanningViewController> *)scanningViewController
                  didFindError:(NSError *)error {
    // Can be ignored. See description of the method
}

- (void)scanningViewControllerDidClose:(UIViewController<PPScanningViewController> *)scanningViewController {

    // As scanning view controller is presented full screen and modally, dismiss it
    [scanningViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanningViewController:(UIViewController<PPScanningViewController> *)scanningViewController
              didOutputResults:(NSArray *)results {

    // Here you process scanning results. Scanning results are given in the array of PPRecognizerResult objects.

    // first, pause scanning until we process all the results
    [scanningViewController pauseScanning];

    NSMutableArray<NSDictionary *> *dictionaryResults = [[NSMutableArray alloc] init];

    const NSString *resultTypeKey = @"ResultType";

    for (id obj in results) {
        if ([obj isKindOfClass:[PPRecognizerResult class]]) {
            PPRecognizerResult *result = (PPRecognizerResult *)obj;

            NSMutableDictionary *dict = [[result getAllStringElements] mutableCopy];

            if ([result isKindOfClass:[PPMrtdRecognizerResult class]]) {
                [dict setObject:@"Mrtd" forKey:resultTypeKey];
            } else if ([result isKindOfClass:[PPUsdlRecognizerResult class]]) {
                [dict setObject:@"Usdl" forKey:resultTypeKey];
            } else if ([result isKindOfClass:[PPEudlRecognizerResult class]]) {
                if (((PPEudlRecognizerResult *)result).country == PPEudlCountryUnitedKingdom) {
                    [dict setObject:@"Ukdl" forKey:resultTypeKey];
                }
            } else if ([result isKindOfClass:[PPEudlRecognizerResult class]]) {
                if (((PPEudlRecognizerResult *)result).country == PPEudlCountryGermany) {
                    [dict setObject:@"Dedl" forKey:resultTypeKey];
                }
            } else if ([result isKindOfClass:[PPEudlRecognizerResult class]]) {
                if (((PPEudlRecognizerResult *)result).country == PPEudlCountryAny) {
                    [dict setObject:@"Eudl" forKey:resultTypeKey];
                }
            } else if ([result isKindOfClass:[PPMyKadRecognizerResult class]]) {
                [dict setObject:@"MyKad" forKey:resultTypeKey];
            } else if ([result isKindOfClass:[PPPdf417RecognizerResult class]]) {
                [dict setObject:@"Pdf417" forKey:resultTypeKey];
            } else if ([result isKindOfClass:[PPBarDecoderRecognizerResult class]]) {
                [dict setObject:@"BarDecoder" forKey:resultTypeKey];
            } else if ([result isKindOfClass:[PPZXingRecognizerResult class]]) {
                [dict setObject:@"ZXing" forKey:resultTypeKey];
            } else if ([result isKindOfClass:[PPBlinkOcrRecognizerResult class]]) {
                PPBlinkOcrRecognizerResult *ocrResult = (PPBlinkOcrRecognizerResult *)result;
                for (NSString *parserName in self.parserNames) {
                    [dict setObject:parserName forKey:[ocrResult parsedResultForName:parserName]];
                }
            }

            [dictionaryResults addObject:dict];
        }
    }

    [self.delegate blinkID:self didOutputResults:dictionaryResults];

    // As scanning view controller is presented full screen and modally, dismiss it
    [scanningViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - recognizers

- (void)addMrtdRecognizer:(PPSettings *)settings {
    PPMrtdRecognizerSettings *mrtdRecognizerSettings = [[PPMrtdRecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:mrtdRecognizerSettings];
}

- (void)addUsdlRecognizer:(PPSettings *)settings {
    PPUsdlRecognizerSettings *usdlRecognizerSettings = [[PPUsdlRecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:usdlRecognizerSettings];
}

- (void)addMyKadRecognizer:(PPSettings *)settings {
    PPMyKadRecognizerSettings *myKadRecognizerSettings = [[PPMyKadRecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:myKadRecognizerSettings];
}

- (void)addEudlRecognizer:(PPSettings *)settings {
    PPEudlRecognizerSettings *eudlRecognizerSettings = [[PPEudlRecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:eudlRecognizerSettings];
}

- (void)addUkdlRecognizer:(PPSettings *)settings {
    PPEudlRecognizerSettings *eudlRecognizerSettings = [[PPEudlRecognizerSettings alloc] initWithEudlCountry:PPEudlCountryUnitedKingdom];
    [settings.scanSettings addRecognizerSettings:eudlRecognizerSettings];
}

- (void)addDedlRecognizer:(PPSettings *)settings {
    PPEudlRecognizerSettings *eudlRecognizerSettings = [[PPEudlRecognizerSettings alloc] initWithEudlCountry:PPEudlCountryGermany];
    [settings.scanSettings addRecognizerSettings:eudlRecognizerSettings];
}

- (void)addPdf417Recognizer:(PPSettings *)settings {
    PPPdf417RecognizerSettings *recognizerSettings = [[PPPdf417RecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:recognizerSettings];
}

- (void)addBardecoderRecognizer:(PPSettings *)settings {
    PPBarDecoderRecognizerSettings *recognizerSettings = [[PPBarDecoderRecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:recognizerSettings];
}

- (void)addZxingRecognizer:(PPSettings *)settings {
    PPZXingRecognizerSettings *recognizerSettings = [[PPZXingRecognizerSettings alloc] init];
    [settings.scanSettings addRecognizerSettings:recognizerSettings];
}

#pragma mark - BlinkID specifics

/**
 * Method allocates and initializes the Scanning coordinator object.
 * Coordinator is initialized with settings for scanning
 *
 *  @param error Error object, if scanning isn't supported
 *
 *  @return initialized coordinator
 */
- (PPCameraCoordinator *)coordinatorWithError:(NSError**)error {

    /** 0. Check if scanning is supported */

    if ([PPCameraCoordinator isScanningUnsupportedForCameraType:self.cameraType error:error]) {
        return nil;
    }


    /** 1. Initialize the Scanning settings */

    // Initialize the scanner settings object. This initialize settings with all default values.
    PPSettings *settings = [[PPSettings alloc] init];
    settings.cameraSettings.cameraType = self.cameraType;

    // tell which metadata you want to receive. Metadata collection takes CPU time - so use it only if necessary!
    settings.metadataSettings.dewarpedImage = YES; // get dewarped image of ID documents


    /** 2. Setup the license key */

    // Visit www.microblink.com to get the license key for your app
    settings.licenseSettings.licenseKey = self.licenseKey;


    /** 3. Set up what is being scanned. See detailed guides for specific use cases. */
    
    /**
     * Add all needed recognizers
     */
    for (PPRecognizerSettings *recognizer in self.recognizers) {
        [settings.scanSettings addRecognizerSettings:recognizer];
    }
    
    /**
     * Add BlinkOCR if parsers exist
     */
    if (self.parsers.count > 0) {
        PPBlinkOcrRecognizerSettings *recognizer = [[PPBlinkOcrRecognizerSettings alloc] init];
        for (PPOcrParserFactory *parser in self.parsers) {
            [recognizer addOcrParser:parser name:[self.parserNames objectAtIndex:[self.parsers indexOfObject:parser]]];
        }
        [settings.scanSettings addRecognizerSettings:recognizer];
    }



    /** 4. Initialize the Scanning Coordinator object */
    
    PPCameraCoordinator *coordinator = [[PPCameraCoordinator alloc] initWithSettings:settings];
    
    return coordinator;
}

#pragma mark - recognizers

- (BOOL)recognizerExists:(PPRecognizerSettings *)recognizer {
    for(PPRecognizerSettings *temp in self.recognizers) {
        if ([temp isKindOfClass:[recognizer class]]) {
            if ([recognizer isKindOfClass:[PPEudlRecognizerSettings class]]) {
                [self.recognizers removeObject:temp];
                [self.recognizers addObject:[[PPEudlRecognizerSettings alloc] initWithEudlCountry:PPEudlCountryAny]];
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL)idExists:(NSString *)id {
    BOOL found = [id isEqualToString:@"Mrtd"] || [id isEqualToString:@"Usdl"] || [id isEqualToString:@"Ukdl"] || [id isEqualToString:@"Dedl"] || [id isEqualToString:@"Eudl"] || [id isEqualToString:@"MyKad"] || [id isEqualToString:@"Pdf417"] || [id isEqualToString:@"BarDecoder"] || [id isEqualToString:@"ZXing"];
    if (found) {
        NSLog(@"Parser ID cannot have same ID (%@) as one of recognizers!\nPlease use different ID for a parser!",id);
        return YES;
    }
    for (NSString *temp in self.parserNames) {
        if ([temp isEqualToString:id]) {
            NSLog(@"Parser ID with selected ID (%@) already exists!\nPlease use different ID!",id);
            return YES;;
        }
    }
    return NO;
    
}

- (void)addMrtdRecognizer {
    PPMrtdRecognizerSettings *recognizer = [[PPMrtdRecognizerSettings alloc] init];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addUsdlRecognizer {
    PPUsdlRecognizerSettings *recognizer = [[PPUsdlRecognizerSettings alloc] init];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addUkdlRecognizer {
    PPEudlRecognizerSettings *recognizer = [[PPEudlRecognizerSettings alloc] initWithEudlCountry:PPEudlCountryUnitedKingdom];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addDedlRecognizer {
    PPEudlRecognizerSettings *recognizer = [[PPEudlRecognizerSettings alloc] initWithEudlCountry:PPEudlCountryGermany];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addEudlRecognizer {
    PPEudlRecognizerSettings *recognizer = [[PPEudlRecognizerSettings alloc] initWithEudlCountry:PPEudlCountryAny];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addMyKadRecognizer {
    PPMyKadRecognizerSettings *recognizer = [[PPMyKadRecognizerSettings alloc] init];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addPdf417Recognizer {
    PPPdf417RecognizerSettings *recognizer = [[PPPdf417RecognizerSettings alloc] init];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addBarDecoderRecognizer {
    PPBarDecoderRecognizerSettings *recognizer = [[PPBarDecoderRecognizerSettings alloc] init];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addZXingRecognizer {
    PPZXingRecognizerSettings *recognizer = [[PPZXingRecognizerSettings alloc] init];
    if(![self recognizerExists:recognizer]) {
        [self.recognizers addObject:recognizer];
    }
}

- (void)addRawParser:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPRawOcrParserFactory alloc] init];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)addAmountParser:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPPriceOcrParserFactory alloc] init];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)addDateParser:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPDateOcrParserFactory alloc] init];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)addEmailParser:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPEmailOcrParserFactory alloc] init];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)addIbanParser:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPIbanOcrParserFactory alloc] init];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)addVinParser:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPVinOcrParserFactory alloc] init];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)addRegexParser:(NSString *)regex id:(NSString *)id {
    if ([self idExists:id]) {
        return;
    }
    PPOcrParserFactory *factory = [[PPRegexOcrParserFactory alloc] initWithRegex:regex];
    factory.isRequired = NO;
    [self.parsers addObject:factory];
    [self.parserNames addObject:id];
}

- (void)clearAllRecognizers {
    [self.recognizers removeAllObjects];
}

- (void)clearAllParsers {
    [self.recognizers removeAllObjects];
    [self.parserNames removeAllObjects];
}


@end
