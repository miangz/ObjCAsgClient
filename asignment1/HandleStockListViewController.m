//
//  HandleStockListViewController.m
//  asignment1
//
//  Created by miang on 6/13/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//
#import "ViewController.h"
#import "HandleStockListViewController.h"
#import "NetworkManager.h"
#import "QNetworkAdditions.h"
#import "NetworkManager.h"
#include <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@interface HandleStockListViewController ()

@end

@implementation HandleStockListViewController{
    NSMutableArray *stockList;
    NSMutableData *message;
    
    NSMutableArray *myIndexPath;
    UIButton *doneBT;
    UIButton *reorderBT;
    
    int count;
    NSString *lastRequest;
}

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;
@synthesize data;

@synthesize table;

@synthesize stockListNO;
@synthesize uid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myIndexPath = [[NSMutableArray alloc]init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-20)];
    table.dataSource = self;
    table.delegate = self;
    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:table];
    
    UIButton *deleteBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteBT.frame = CGRectMake(230, 25, 70, 35);
    [deleteBT setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBT addTarget:self action:@selector(removeCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBT];
    
    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBT.frame = CGRectMake(10, 25, 70, 35);
    [backBT setTitle:@"<Back" forState:UIControlStateNormal];
    [backBT addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBT];
    
    reorderBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reorderBT.frame = CGRectMake(90, 25, 30, 35);
    [reorderBT setTitle:@"Edit" forState:UIControlStateNormal];
    [reorderBT addTarget:self action:@selector(reorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reorderBT];
    
    doneBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneBT.frame = CGRectMake(90, 25, 40, 35);
    [doneBT setTitle:@"Done" forState:UIControlStateNormal];
    [doneBT addTarget:self action:@selector(reorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBT];
    doneBT.hidden = YES;
    
}




-(void)viewDidAppear:(BOOL)animated{
    [self startServer];
    lastRequest = [NSString stringWithFormat:@"getAllStockList:%@",uid];
    [self sendMessage:lastRequest];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.fileStream close];
    [self.networkStream close];
    [self stopServer:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return stockList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSString *str = [stockList objectAtIndex:indexPath.row];
    if (str.length<8) {
        cell.textLabel.text = @"This list is empty.";
        return cell;
    }
    str = [str substringFromIndex:8];
    cell.textLabel.text = [str stringByReplacingOccurrencesOfString:@"+" withString:@","];;
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    int source = sourceIndexPath.row;
    int des = destinationIndexPath.row;
    if (source == stockListNO) {
        stockListNO = destinationIndexPath.row;
    }else if(source < stockListNO && des > stockListNO){
        stockListNO--;
    }else if(source > stockListNO && des <= stockListNO){
        stockListNO++;
    }
    NSString *change = [stockList objectAtIndex:sourceIndexPath.row];
    [stockList removeObjectAtIndex:sourceIndexPath.row];
    [stockList insertObject:change atIndex:destinationIndexPath.row];
    [self reorderListFrom:sourceIndexPath to:destinationIndexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row == stockListNO) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You can't delete the viewing list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }else if(indexPath.row < stockListNO){
            stockListNO--;
        }
        NSString *string = [NSString stringWithFormat:@"removeList:%@:%d",uid,indexPath.row];
        [self sendMessage:string];
        [stockList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == stockListNO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You can't delete the viewing list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if([myIndexPath containsObject: indexPath] ){
        UITableViewCell *formerSelectedcell = [tableView cellForRowAtIndexPath:indexPath];
        // finding the already selected cell
        [formerSelectedcell setAccessoryType:UITableViewCellAccessoryNone];
        [myIndexPath removeObject:indexPath];
    }else {
        // 'select' the new cell
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        if (myIndexPath.count == 0) {
            [myIndexPath addObject:indexPath];
        }
        else{
            for (int i=0;i<myIndexPath.count;i++) {
                if ([[myIndexPath objectAtIndex:i]row]>indexPath.row) {
                    [myIndexPath insertObject:indexPath atIndex:i];
                    return;
                }else if(i==myIndexPath.count-1){
                    [myIndexPath addObject:indexPath];
                    return;
                }
            }
            
            
        }
    }
    
}


#pragma mark manage button

-(void)back{
//    [self dismissViewControllerAnimated:YES completion:nil];
    ViewController *view = [[ViewController alloc]init];
    view.uid = uid;
    view.stockListNO = stockListNO;
    [self presentViewController:view animated:YES completion:nil];
}

-(void)reorder{
    if (table.editing == YES) {
        table.editing = NO;
        doneBT.hidden = YES;
        reorderBT.hidden = NO;
    }else{
        table.editing = YES;
        doneBT.hidden = NO;
        reorderBT.hidden = YES;
    }
}

-(void)removeCell{
    NSMutableString *string = [[NSMutableString alloc]initWithString:@"removeList:"];
    [string appendString:uid];
    [string appendString:@":"];
    for (int i=myIndexPath.count-1; i>=0; i--) {
        NSIndexPath *index = [myIndexPath objectAtIndex:i];
        [stockList removeObjectAtIndex:index.row];
        if (i != myIndexPath.count-1) {
            [string appendString:@"+"];
        }
        if (index.row < stockListNO) {
            stockListNO--;
        }
        [string appendString:[NSString stringWithFormat:@"%d",index.row]];
        if (i == 0) {
            [myIndexPath removeAllObjects];
            [table reloadData];
            [self sendMessage:string];
        }
    }
}

-(void)reorderListFrom:(NSIndexPath *)sourceIndexPath to:(NSIndexPath *)destinationIndexPath{
    
    NSString *string = [NSString stringWithFormat:@"reorderList:%@:%d:%d",uid,sourceIndexPath.row,destinationIndexPath.row];
    [self sendMessage:string];
}

#pragma mark manage messege
- (void)sendMessage:(NSString *)string{
    count = 0;
    if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
        [self.networkStream close];
    }
    
    [self initNetworkCommunication];
    
    //    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@" , string);
	data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
	[self.networkStream write:[data bytes] maxLength:[data length]];
    
}

- (void)sendData:(NSData *)mydata{
    if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
        [self.networkStream close];
    }
    
    [self initNetworkCommunication];
	[self.networkStream write:[mydata bytes] maxLength:[mydata length]];
    
}

- (void) initNetworkCommunication {
    NSOutputStream *    output;
    BOOL                success;
    NSNetService *      netService;
    
    netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSUpload._tcp." name:@"Test"];
    assert(netService != nil);
    
    
    success = [netService qNetworkAdditions_getInputStream:NULL outputStream:&output];
    assert(success);
    
    self.networkStream = output;
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.networkStream open];
    
    // Tell the UI we're sending.
    
    [self sendDidStart];
    
}
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
	//NSLog(@"stream event %i", eventCode);
    
    //    static int c = 0;
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
            
			if (aStream == self.fileStream) {
                
                uint8_t buffer[5000];
				long len;
				
				while ([self.fileStream hasBytesAvailable]) {
					len = [self.fileStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        NSData *d = [[NSData alloc]initWithBytes:buffer length:len];
                        if (output != nil) {
                            if (message == nil) {
                                message = [NSMutableData new];
                            }
                            [message appendData:d];
                        }
					}
				}
                
                NSArray *array;
                if (message != nil) {
                    @try {
                        array = [NSKeyedUnarchiver unarchiveObjectWithData:message];
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"TRY unarchiveObjectWithData ERROR : %@",exception);
                    }
                    @finally{
                        if (array == nil) {
                            NSString *str = [[NSString alloc]initWithData:message encoding:NSASCIIStringEncoding];
                            NSLog(@"string : %@",str);
                            
                            if (count > 0) {
                                return;
                            }
                            
                            NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                            if (rng.length > 0){
                                [self sendMessage:lastRequest];
                            }
                        }else{
                            NSLog(@"array : %@",array);
                            if ([[array objectAtIndex:0]isEqualToString:@"getAllStockList"]) {
                                stockList = nil;
                                stockList = [[NSMutableArray alloc]initWithArray:[array objectAtIndex:1]];
                                [table reloadData];
                                count++;
                            }
                        }
                        message = nil;
                    }
                }
			}
			break;
            
        case NSStreamEventHasSpaceAvailable:
            break;
		default:
            //			NSLog(@"Unknown event %@,%@",aStream,inputStream);
            break;
            
	}
}


#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)sendDidStart
{
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Send succeeded";
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        self.networkStream.delegate = nil;
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    [self sendDidStopWithStatus:statusString];
}
//Server Receive
- (void)serverDidStartOnPort:(NSUInteger)port
{
    assert( (port != 0) && (port < 65536) );
    NSLog(@"%@", [NSString stringWithFormat:@"Started on port %zu", (size_t) port]);
}
- (void)serverDidStopWithReason:(NSString *)reason
{
    if (reason == nil) {
        reason = @"Stopped";
    }
}
- (void)receiveDidStart
{
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}
- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Receive succeeded";
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}


- (void)startReceive:(int)fd
{
    CFReadStreamRef     readStream;
    
    assert(fd >= 0);
    
    
    //    [self.fileStream open];
    
    // Open a stream based on the existing socket file descriptor.  Then configure
    // the stream for async operation.
    
    CFStreamCreatePairWithSocket(NULL, fd, &readStream, NULL);
    assert(readStream != NULL);
    
    self.fileStream = (__bridge NSInputStream *) readStream;
    
    CFRelease(readStream);
    
    [self.fileStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    self.fileStream.delegate = self;
    [self.fileStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.fileStream open];
    
    // Tell the UI we're receiving.
    
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
{
    if (self.fileStream != nil) {
        self.fileStream.delegate = nil;
        [self.fileStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.fileStream close];
        self.fileStream = nil;
    }
    if (self.networkStream != nil) {
        [self.networkStream close];
        self.networkStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
}


- (BOOL)isStarted
{
    return (self.netService != nil);
}

- (BOOL)isReceiving
{
    return (self.fileStream != nil);
}
- (void)acceptConnection:(int)fd
{
    [self startReceive:fd];
}

static void AcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
// Called by CFSocket when someone connects to our listening socket.
// This implementation just bounces the request up to Objective-C.
{
    
    HandleStockListViewController  *  obj;
    
#pragma unused(type)
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(address)
    // assert(address == NULL);
    assert(data != NULL);
    
    obj = (__bridge HandleStockListViewController *) info;
    assert(obj != nil);
    
    assert(s == obj->_listeningSocket);
#pragma unused(s)
    
    [obj acceptConnection:*(int *)data];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
// A NSNetService delegate callback that's called if our Bonjour registration
// fails.  We respond by shutting down the server.
//
// This is another of the big simplifying assumptions in this sample.
// A real server would use the real name of the device for registrations,
// and handle automatically renaming the service on conflicts.  A real
// client would allow the user to browse for services.  To simplify things
// we just hard-wire the service name in the client and, in the server, fail
// if there's a service name conflict.
{
#pragma unused(sender)
    assert(sender == self.netService);
#pragma unused(errorDict)
    
    [self stopServer:@"Registration failed"];
}

- (void)startServer
{
    BOOL                success;
    int                 err;
    int                 fd;
    int                 junk;
    struct sockaddr_in  addr;
    NSUInteger          port;
    
    // Create a listening socket and use CFSocket to integrate it into our
    // runloop.  We bind to port 0, which causes the kernel to give us
    // any free port, then use getsockname to find out what port number we
    // actually got.
    
    port = 0;
    
    fd = socket(AF_INET, SOCK_STREAM, 0);
    success = (fd != -1);
    
    if (success) {
        memset(&addr, 0, sizeof(addr));
        addr.sin_len    = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port   = 0;
        addr.sin_addr.s_addr = INADDR_ANY;
        err = bind(fd, (const struct sockaddr *) &addr, sizeof(addr));
        success = (err == 0);
    }
    if (success) {
        err = listen(fd, 5);
        success = (err == 0);
    }
    if (success) {
        socklen_t   addrLen;
        
        addrLen = sizeof(addr);
        err = getsockname(fd, (struct sockaddr *) &addr, &addrLen);
        success = (err == 0);
        
        if (success) {
            assert(addrLen == sizeof(addr));
            port = ntohs(addr.sin_port);
        }
    }
    if (success) {
        CFSocketContext context = { 0, (__bridge void *) self, NULL, NULL, NULL };
        
//        assert(self->_listeningSocket == NULL);
        self->_listeningSocket = CFSocketCreateWithNative(
                                                          NULL,
                                                          fd,
                                                          kCFSocketAcceptCallBack,
                                                          AcceptCallback,
                                                          &context
                                                          );
        success = (self->_listeningSocket != NULL);
        
        if (success) {
            CFRunLoopSourceRef  rls;
            
            fd = -1;        // listeningSocket is now responsible for closing fd
            
            rls = CFSocketCreateRunLoopSource(NULL, self.listeningSocket, 0);
            assert(rls != NULL);
            
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
            
            CFRelease(rls);
        }
    }
    
    // Now register our service with Bonjour.  See the comments in -netService:didNotPublish:
    // for more info about this simplifying assumption.
    
    if (success) {
        self.netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSDownload._tcp." name:@"Test" port:port];
        success = (self.netService != nil);
    }
    if (success) {
        self.netService.delegate = self;
        
        [self.netService publishWithOptions:NSNetServiceNoAutoRename];
        
        // continues in -netServiceDidPublish: or -netService:didNotPublish: ...
    }
    
    // Clean up after failure.
    
    if ( success ) {
        assert(port != 0);
        [self serverDidStartOnPort:port];
    } else {
        [self stopServer:@"Start failed"];
        if (fd != -1) {
            junk = close(fd);
            assert(junk == 0);
        }
    }
}

- (void)stopServer:(NSString *)reason
{
    if (self.isReceiving) {
        [self stopReceiveWithStatus:@"Cancelled"];
    }
    if (self.netService != nil) {
        [self.netService stop];
        self.netService = nil;
    }
    if (self.listeningSocket != NULL) {
        CFSocketInvalidate(self.listeningSocket);
        CFRelease(self->_listeningSocket);
        self->_listeningSocket = NULL;
    }
    [self serverDidStopWithReason:reason];
}
- (BOOL)isSending
{
    return (self.networkStream != nil);
}


@end
