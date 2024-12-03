classdef AttackKnowledge < uint16
    % See ISO/SAE 21434:2021 G.2.2.3.
    enumeration
        KN_Public(0), % Public information concerning the item or component (e.g. as gained from the Internet).
        KN_Restricted(3), % Info concerning the item or component (e.g. knowledge that is controlled within the developer organization and shared with other organizations under a non-disclosure agreement).
        KN_Confidential(7), % Info about the item or component (e.g. knowledge that is shared between discrete teams within the developer organization, access to which is constrained only to members of the specified teams).
        KN_StrictlyConfidential(11) % information about the item or component (e.g. knowledge that is known by only a few individuals, access to which is very tightly controlled on a strict need to know basis and individual undertaking)
    end
end

