#cs
--------------------------------------------------------------------------------
AutoIt Version: 3.0
Language:       English
Platform:       All
Author:         mrider

Script Function:
    Unit tests of the functions in "Hash.au3"
--------------------------------------------------------------------------------
#ce
#include <Hash.au3>

Global $retVal = 0;
Global $testRecord = 0;
Global $run = 0;

test_HashF_KillAll();
test_HashF_NewInstance();
test_HashF_Put();
test_HashF_Get();
test_HashF_RemovePair();
test_HashF_RemoveHash();
test_HashF_Grow();
test_HashF_Shrink();
test_HashF_DefaultResizeAmt();
test_HashF_KeyPairCount();
test_HashF_Keys();
test_HashF_Values();
test_HashF_Entries();
test_HashF_ValidatePtr();
test_HashF_SortKeysAsc();
test_HashF_SortValsAsc();
test_HashF_SortKeysDesc();
test_HashF_SortValsDesc();


If ( $testRecord == 0 ) Then
    MsgBox( 64, "Success", "All valid tests passed" );
EndIf


Func test_HashF_KillAll()
    ; This test depends on having values in the hash - and we don't know if this works yet.
    ; I'll just break encapsulation and modify the global value directly...
    Dim $_HashG_Container[1][1][1];
    If ( IsArray($_HashG_Container) == 0 ) Then 
        MsgBox(0, "Invalid Test", "Test method failed" );
    EndIf
    _HashF_KillAll();
    If( IsArray($_HashG_Container) == 1 ) Then
        bark( "HashF_KillAll failed to clear the hash" );
    EndIf
EndFunc

Func test_HashF_NewInstance()
    _HashF_KillAll();
    Local $testVal = _HashF_NewInstance();
    If ( $testVal <> 0 ) Then
        bark( "Expected 0, got " & $testVal & " _HashF_NewInstance did not create the first hash" );
    EndIf
    $testVal = _HashF_NewInstance();
    If ( $testVal <> 1 ) Then
        bark( "Expected 1, got " & $testVal & " _HashF_NewInstance did not create the second hash" );
    EndIf
EndFunc


Func test_HashF_Put()
    _HashF_KillAll();
    Local $testVal;
    Local $err;
    
    ;See if it'll complain about not initialized
    _HashF_Put( "x", "y" )
    $err = @error;
    $err = BitAND( $err, $_HashC_NotInitialized );
      If ( $err <> $_HashC_NotInitialized ) Then
        bark( "HashF_Put allowed insert into uninitialized hash" );
    EndIf
    
    ; Since I don't officially know whether "get" works yet, we'll break encapsulation and get the value directly
    $testVal = _HashF_NewInstance();
    Local $key;
    Local $val;
    _HashF_Put( "a", "A" );
    _HashF_Put( "b", "B" );
    $key = $_HashG_container[0][1][0];
    $val = $_HashG_container[0][1][1];
    If ( ( $key <> "a" ) OR ( $val <> "A" ) ) Then
        bark( "HashF_Put did not properly insert the first key value pair" );
    EndIf
    $key = $_HashG_container[0][2][0];
    $val = $_HashG_container[0][2][1];
    If ( ( $key <> "b" ) OR ( $val <> "B" ) ) Then
        bark( "HashF_Put did not properly insert the second key value pair" );
    EndIf
    
    ;Check whether we can get an invalid pointer
    
    ; Now we see if we can have more than one hash instance
    $testVal = _HashF_NewInstance();
    _HashF_Put( "1", "one", $testVal );
    $key = $_HashG_container[1][0][0];
    $val = $_HashG_container[1][0][1];
    If ( ( $key <> "1" ) OR ( $val <> "1" ) ) Then
        bark( "HashF_Put did not properly insert the second key value pair" );
    EndIf
EndFunc

Func test_HashF_Get()
    _HashF_KillAll();
    Local $get;
    
    ;Try single default
    _HashF_NewInstance();
    _HashF_Put( "a", "A" );
    _HashF_Put( "b", "B" );
    $get = _HashF_Get( "a" );
    If ( $get <> "A" ) Then
        bark( "HashF_Get default failed" );
    EndIf
    $get = _HashF_Get( "b" );
    If ( $get <> "B" ) Then
        bark( "HashF_Get default failed" );
    EndIf
    
    _HashF_KillAll();
    
    ;Try multiples 
    Local $hashChars = _HashF_NewInstance();
    Local $hashNums = _HashF_NewInstance();
    _HashF_Put( "a", "A", $hashChars );
    _HashF_Put( "b", "B", $hashChars );
    _HashF_Put( "1", "one", $hashNums );
    _HashF_Put( "2", "two", $hashNums );
    
    
    $get = _HashF_Get( "a", $hashChars );
    If ( $get <> "A" ) Then
        bark( "Expected 'A', got '" & $get & "' - _HashF_Get first instance failed" );
    EndIf
    $get = _HashF_Get( "b", $hashChars );
    If ( $get <> "B" ) Then
        bark( "Expected 'B', got '" & $get & "' - _HashF_Get first instance failed" );
    EndIf
    
    $get = _HashF_Get( "1", $hashNums );
    If ( $get <> "one" ) Then
        bark( "Expected 'one', got '" & $get & "' - _HashF_Get second instance failed" );
    EndIf
    
    $get = _HashF_Get( "2", $hashNums );
    If ( $get <> "two" ) Then
        bark( "Expected 'two', got '" & $get & "' - _HashF_Get second instance failed" );
    EndIf
    
    $get = _HashF_Get( "1", $hashChars );
    If ( $get <> 0 ) Then
        bark( "Expected '0', got '" & $get & "' - _HashF_Get first incorrect instance failed" );
    EndIf
    
    $get = _HashF_Get( "a", $hashNums );
    If ( $get <> 0 ) Then
        bark( "Expected '0', got '" & $get & "' - _HashF_Get second incorrect instance failed" );
    EndIf
    
EndFunc

Func test_HashF_RemovePair()
    _HashF_KillAll();
    _HashF_NewInstance();
    For $i = 1 To 10
        _HashF_Put( Chr( $i + 64 ), Chr( $i + 97 ) );
    Next
    
    Local $lastKey = $_HashG_container[0][ (UBound($_HashG_container, 2)-1)][0];
    Local $lastVal = $_HashG_container[0][ (UBound($_HashG_container, 2)-1)][1];
    Local $nextToLastKey = $_HashG_container[0][ (UBound($_HashG_container, 2)-2)][0];
    Local $nextToLastVal = $_HashG_container[0][ (UBound($_HashG_container, 2)-2)][1];
    _HashF_RemovePair( $lastKey );
    Local $newLastKey = $_HashG_container[0][ (UBound($_HashG_container, 2)-1)][0];
    Local $newLastVal = $_HashG_container[0][ (UBound($_HashG_container, 2)-1)][1];
    If ( ( $lastKey == $newLastKey ) Or ( $lastVal == $newLastVal ) ) Then
        bark( "HashF_RemovePair: Old key->val pair wasn't removed" );
    EndIf
    If ( ( $nextToLastKey <> $newLastKey ) Or ( $nextToLastVal <> $newLastVal ) ) Then
        bark( "HashF_RemovePair: Removing key->val pair mangled previous pair" );
    EndIf
    
    Local $lowKey = $_HashG_container[0][2][0];
    Local $lowVal = $_HashG_container[0][2][0];
    Local $midKey = $_HashG_container[0][3][0];
    Local $midVal = $_HashG_container[0][3][0];
    Local $hiKey  = $_HashG_container[0][4][0];
    Local $hiVal  = $_HashG_container[0][4][0];
EndFunc

Func test_HashF_RemoveHash()
    _HashF_KillAll();
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    Local $hash3 = _HashF_NewInstance();
    _HashF_Put( "a", "A", $hash1 );
    _HashF_Put( "b", "B", $hash2 );
    _HashF_Put( "c", "C", $hash3 );
    
    Local $a, $b, $c;
    $a = _HashF_Get( "a", $hash1 );
    $b = _HashF_Get( "b", $hash2 );
    $c = _HashF_Get( "c", $hash3 );
    If ( ($a <> "A") Or ($b <> "B") Or ($c <> "C") ) Then
        bark( "Remove test invalid" );
    EndIf
    
    _HashF_RemoveHash( $hash2 );
    $a = _HashF_Get( "a", $hash1 );
    $b = _HashF_Get( "b", $hash2 );
    $c = _HashF_Get( "c", $hash3 );
    If ( ($a <> "A") Or ($b <> 0) Or ($c <> "C") ) Then
        bark( "Remove test failed on first remove" );
    EndIf
    
    _HashF_RemoveHash( $hash1 );
    $a = _HashF_Get( "a", $hash1 );
    $c = _HashF_Get( "c", $hash3 );
    If ( ($a <> 0) Or ($c <> "C") ) Then
        bark( "Remove test failed on second remove" );
        iterateHash();
    EndIf
    
    _HashF_RemoveHash( $hash3 );
    $c = _HashF_Get( "c", $hash3 );
    If ( $c <> 0 ) Then
        bark( "Remove test failed on final remove" );
    EndIf
    
EndFunc

Func test_HashF_Grow()
    _HashF_KillAll();
    _HashF_NewInstance();
    Local $curSize = UBound( $_HashG_container, 2 );
    Local $retSize = _HashF_Grow();
    Local $newSize = UBound( $_HashG_container, 2 );
    If ( ( $retSize <> ( $newSize-1 ) ) Or ( $curSize >= $retSize ) ) Then
        bark( "Hash did not grow properly" );
    EndIf
EndFunc

Func test_HashF_Shrink()
    _HashF_KillAll();
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    _HashF_Put( "a", "A", $hash1 );
    For $i = 1 to 20
        _HashF_Put( Chr( $i + 64 ), Chr( $i + 96 ), $hash2 )
    Next
    Local $largest = UBound( $_HashG_container, 2 );     //This is as big as it'll get
    For $i = 5 To 20
        _HashF_RemovePair( Chr( $i + 64 ), $hash2 );
    Next
    _HashF_Shrink();
    Local $mid = UBound( $_HashG_container, 2 );         //Should shrink to = $_HashG_initSize
    _HashF_Shrink( 1 );
    Local $smallest = UBound( $_HashG_container, 2 );    //Should shrink to num of elements
    If ( ( $largest <= $mid ) Or ( $largest <= $smallest ) ) Then
        bark( "Hash doesn't appear to have shrunk at all" );
    EndIf
    If ( $mid <= $smallest ) Then
        bark( "Hash stopped shrinking after first try" );
    EndIf
    If ( $mid <> ($_HashG_initSize + 1) ) Then
        bark( "Hash didn't shrink to proper size on first try" );
    EndIf
    If ( $smallest <> ( $_HashG_container[1][0][0] + 1 ) ) Then
        bark( "Hash didn't shrink to proper size on second try" );
    EndIf
EndFunc

Func test_HashF_DefaultResizeAmt()
    Local $oldAmt = $_HashG_resizeAdder;
    
    ;Make sure validation works
    _HashF_DefaultResizeAmt( "x" );
    If ( $oldAmt <> $_HashG_resizeAdder ) Then
        bark( "HashF_DefaultResizeAmt accepted a non-numeric argument" );
    EndIf
    _HashF_DefaultResizeAmt( "-5" );
    If ( $oldAmt <> $_HashG_resizeAdder ) Then
        bark( "HashF_DefaultResizeAmt accepted a negative number as an argument" );
    EndIf
    
    ;Change it
    _HashF_DefaultResizeAmt( $oldAmt * 2 );
    If ( ( $oldAmt * 2 ) <> $_HashG_resizeAdder ) Then
        bark( "Couldn't increase resize adder" );
    EndIf
    _HashF_DefaultResizeAmt( $oldAmt );
    If ( $oldAmt <> $_HashG_resizeAdder ) Then
        bark( "Couldn't reduce resize adder" );
    EndIf
EndFunc

Func test_HashF_KeyPairCount()
    _HashF_KillAll();
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    Local $test1 = 17;
    Local $test2 = 9;
    For $i = 1 to $test1
        _HashF_Put( Chr( $i + 64 ), Chr( $i + 96 ), $hash1 )
    Next
    For $i = 1 to $test2
        _HashF_Put( Chr( $i + 64 ), Chr( $i + 96 ), $hash2 )
    Next
    If ( $test1 <> _HashF_KeyPairCount() ) Then
        bark( "KeyPairCount for default hash didn't work" );
    EndIf
    If ( $test1 <> _HashF_KeyPairCount( $hash1 ) ) Then
        bark( "KeyPairCount for hash 1 didn't work" );
    EndIf
    If ( $test2 <> _HashF_KeyPairCount( $hash2 ) ) Then
        bark( "KeyPairCount for hash 2 didn't work" );
    EndIf
EndFunc

Func test_HashF_Keys()
    _HashF_KillAll();
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    
    _HashF_Put( "a", "A", $hash1 );
    _HashF_Put( "b", "B", $hash1 );
    _HashF_Put( "c", "C", $hash1 );
    
    _HashF_Put( "x", "X", $hash2 );
    _HashF_Put( "y", "Y", $hash2 );
    _HashF_Put( "z", "Z", $hash2 );
    
    Local $defKeys = _HashF_Keys();
    Local $aKeys = _HashF_Keys( $hash1 );
    Local $bKeys = _HashF_Keys( $hash2 );
    If ( ( $defKeys[0] <> 3 ) Or ( $defKeys[1] <> "a" ) Or ($defKeys[2] <> "b" ) Or ( $defKeys[3] <> "c" ) ) Then
        bark( "Default hash keys not returned properly" );
    EndIf
    
    If ( ( $defKeys[0] <> 3 ) Or ( $aKeys[1] <> "a" ) Or ( $aKeys[2] <> "b" ) Or ($aKeys[3] <> "c" ) ) Then
        bark( "Hash 1 keys not returned properly" );
    EndIf
    
    If ( ( $defKeys[0] <> 3 ) Or ( $bKeys[1] <> "x" ) Or ( $bKeys[2] <> "y" ) Or ( $bKeys[3] <> "z" ) ) Then
        bark( "Hash 2 keys not returned properly" );
    EndIf
    
EndFunc

Func test_HashF_Values()
    _HashF_KillAll();
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    
    _HashF_Put( "a", "A", $hash1 );
    _HashF_Put( "b", "B", $hash1 );
    _HashF_Put( "c", "C", $hash1 );
    
    _HashF_Put( "x", "X", $hash2 );
    _HashF_Put( "y", "Y", $hash2 );
    _HashF_Put( "z", "Z", $hash2 );
    
    Local $defVals = _HashF_Values();
    Local $aVals = _HashF_Values( $hash1 );
    Local $bVals = _HashF_Values( $hash2 );
    If ( ( $defVals[0] <> 3 ) Or ( $defVals[1] <> "A" ) Or ($defVals[2] <> "B" ) Or ( $defVals[3] <> "C" ) ) Then
        bark( "Default hash values not returned properly" );
    EndIf
    
    If ( ( $aVals[0] <> 3 ) Or ( $aVals[1] <> "A" ) Or ( $aVals[2] <> "B" ) Or ($aVals[3] <> "C" ) ) Then
        bark( "Hash 1 values not returned properly" );
    EndIf
    
    If ( ( $bVals[0] <> 3 ) Or ( $bVals[1] <> "X" ) Or ( $bVals[2] <> "Y" ) Or ( $bVals[3] <> "Z" ) ) Then
        bark( "Hash 2 values not returned properly" );
    EndIf
    
EndFunc

Func test_HashF_Entries()
    _HashF_KillAll();
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    
    _HashF_Put( "a", "A", $hash1 );
    _HashF_Put( "b", "B", $hash1 );
    _HashF_Put( "c", "C", $hash1 );
    
    _HashF_Put( "x", "X", $hash2 );
    _HashF_Put( "y", "Y", $hash2 );
    _HashF_Put( "z", "Z", $hash2 );
    
    Local $pairs1 = _HashF_Entries( $hash1 );
    Local $keys1 = _HashF_Keys( $hash1 );
    Local $vals1 = _HashF_Values( $hash1 );
    
    Local $pairs2 = _HashF_Entries( $hash2 );
    Local $keys2 = _HashF_Keys( $hash2 );
    Local $vals2 = _HashF_Values( $hash2 );
    
    For $i = 0 To $keys1[0]
        If ( ( $keys1[$i] <> $pairs1[$i][0] ) Or ( $vals1[$i] <> $pairs1[$i][1] ) ) Then
            bark( "HashF_Entries did not pass correct key->value pair for first hash" );
        EndIf
        If ( ( $keys2[$i] <> $pairs2[$i][0] ) Or ( $vals2[$i] <> $pairs2[$i][1] ) ) Then
            bark( "HashF_Entries did not pass correct key->value pair for second hash" );
            bark( "key = " & $keys2[$i] & "    pair = " & $pairs2[$i][0] );
            bark( "val = " & $vals2[$i] & "    pair = " & $pairs2[$i][1] );
        EndIf
    Next
EndFunc

Func test_HashF_ValidatePtr()
    _HashF_KillAll();
    If ( _HashF_ValidatePtr( 1 ) == 0 ) Then
        bark( "HashF_ValidatePtr validated an empty hash" );
    EndIf
    Local $hash1 = _HashF_NewInstance();
    Local $hash2 = _HashF_NewInstance();
    If ( ( _HashF_ValidatePtr( $hash1 ) <> 0 ) Or ( _HashF_ValidatePtr( $hash2 ) <> 0 ) ) Then
        bark( "HashF_ValidatePtr did not validate freshly created hashes" );
    EndIf
    If (  _HashF_ValidatePtr( 3 ) == 0 ) Then
        bark( "HashF_ValidatePtr validated a non-existant hash" );
    EndIf
EndFunc


Func test_HashF_SortKeysAsc()
    _HashF_KillAll();
    Local $hash = _HashF_NewInstance();
    For $i = 0 to 25
        _HashF_Put( chr( 65 + $i ), Random( 1, 100, 1 ) );
    Next
    _HashF_Grow();
    Local $last = UBound( $_HashG_container, 2 ) - 1;
    $_HashG_container[0][$last][0] = "x";
    $_HashG_container[0][$last][1] = "y";
    _HashF_Shuffle( $hash );
    
    _HashF_SortKeysAsc( $hash );
    Local $hash_keys = _HashF_Keys( $hash );
    For $i = 1 to ( $hash_keys[0] - 1 )
        If ( $hash_keys[$i] > $hash_keys[$i + 1] ) Then
            bark( "HashF_SortKeysAsc did not sort properly" );
        EndIf
    Next
    If ( $_HashG_container[0][$last][0] <> "x" ) Then
        bark( "Keys outside the end of the hash were lost" );
    EndIf
    If ( $_HashG_container[0][$last][1] <> "y" ) Then
        bark( "Values outside the end of the hash were lost" );
    EndIf
EndFunc


Func test_HashF_SortValsAsc()
    _HashF_KillAll();
    Local $hash = _HashF_NewInstance();
    For $i = 0 to 25
        _HashF_Put( chr( 65 + $i ), Random( 1, 100, 1 ) );
    Next
    _HashF_Grow();
    Local $last = UBound( $_HashG_container, 2 ) - 1;
    $_HashG_container[0][$last][0] = "x";
    $_HashG_container[0][$last][1] = "y";
    _HashF_Shuffle( $hash );
    
    _HashF_SortValsAsc( $hash );
    Local $hash_vals = _HashF_Values( $hash );
    For $i = 1 to ( $hash_vals[0] - 1 )
        If ( $hash_vals[$i] > $hash_vals[$i + 1] ) Then
            bark( "HashF_SortValsAsc did not sort properly" );
        EndIf
    Next
    If ( $_HashG_container[0][$last][0] <> "x" ) Then
        bark( "Keys outside the end of the hash were lost" );
    EndIf
    If ( $_HashG_container[0][$last][1] <> "y" ) Then
        bark( "Values outside the end of the hash were lost" );
    EndIf
EndFunc


Func test_HashF_SortKeysDesc()
    _HashF_KillAll();
    Local $hash = _HashF_NewInstance();
    For $i = 0 to 25
        _HashF_Put( chr( 65 + $i ), Random( 1, 100, 1 ) );
    Next
    _HashF_Grow();
    Local $last = UBound( $_HashG_container, 2 ) - 1;
    $_HashG_container[0][$last][0] = "x";
    $_HashG_container[0][$last][1] = "y";
    _HashF_Shuffle( $hash );
    
    _HashF_SortKeysDesc( $hash );
    Local $hash_keys = _HashF_Keys( $hash );
    For $i = 1 to ( $hash_keys[0] - 1 )
        If ( $hash_keys[$i] < $hash_keys[$i + 1] ) Then
            bark( "HashF_SortKeysDesc did not sort properly" );
        EndIf
    Next
    If ( $_HashG_container[0][$last][0] <> "x" ) Then
        bark( "Keys outside the end of the hash were lost" );
    EndIf
    If ( $_HashG_container[0][$last][1] <> "y" ) Then
        bark( "Values outside the end of the hash were lost" );
    EndIf
EndFunc

Func test_HashF_SortValsDesc()
    _HashF_KillAll();
    Local $hash = _HashF_NewInstance();
    For $i = 0 to 25
        _HashF_Put( chr( 65 + $i ), Random( 1, 100, 1 ) );
    Next
    _HashF_Grow();
    Local $last = UBound( $_HashG_container, 2 ) - 1;
    $_HashG_container[0][$last][0] = "x";
    $_HashG_container[0][$last][1] = "y";
    _HashF_Shuffle( $hash );
    
    _HashF_SortValsDesc( $hash );
    Local $hash_vals = _HashF_Values( $hash );
    For $i = 1 to ( $hash_vals[0] - 1 )
        If ( $hash_vals[$i] < $hash_vals[$i + 1] ) Then
            bark( "HashF_SortValsDesc did not sort properly" );
        EndIf
    Next
    If ( $_HashG_container[0][$last][0] <> "x" ) Then
        bark( "Keys outside the end of the hash were lost" );
    EndIf
    If ( $_HashG_container[0][$last][1] <> "y" ) Then
        bark( "Values outside the end of the hash were lost" );
    EndIf
EndFunc


;------------ Convenience stuff --------------
Func bark( $text )
    $retVal = MsgBox( 17, "Test Failed", $text );
    $testRecord = $testRecord + 1;
    If ( $retVal == 2 ) Then
        $run = 1;
        Return;
    EndIf
EndFunc



Func iterateHash()
    Local $x = UBound( $_HashG_container, 1 ) - 1;
    Local $y = UBound( $_HashG_container, 2 ) - 1;
    Local $z = UBound( $_HashG_container, 3 ) - 1;
    For $i = 0 To $x
        For $j = 0 To $y
            For $k = 0 To $z
                MsgBox( 0, "[" & $i & "][" & $j & "][" & $k & "]", $_HashG_container[$i][$j][$k] );
            Next
        Next
    Next
EndFunc
