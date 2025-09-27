//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title AnonymousFeedback
 * @dev A decentralized anonymous feedback board for honest, categorized feedback
 * @author WhisperOnChain
 */
contract AnonymousFeedback {
    // Enums
    enum FeedbackCategory {
        POSITIVE, // 0
        CONSTRUCTIVE, // 1
        IDEAS // 2
    }

    enum VoteType {
        UPVOTE, // 0
        DOWNVOTE // 1
    }

    // Structs
    struct Feedback {
        uint256 id;
        string content;
        FeedbackCategory category;
        address submitter;
        uint256 timestamp;
        uint256 upvotes;
        uint256 downvotes;
        bool isActive;
        string metadata; // For additional context like tags, etc.
    }

    struct Vote {
        VoteType voteType;
        uint256 timestamp;
    }

    // State Variables
    address public immutable owner;
    uint256 public totalFeedbackCount;
    uint256 public totalVotes;

    // Mappings
    mapping(uint256 => Feedback) public feedbacks;
    mapping(address => mapping(uint256 => Vote)) public userVotes; // user => feedbackId => vote
    mapping(address => uint256[]) public userFeedbackIds; // user => array of feedback IDs they submitted
    mapping(FeedbackCategory => uint256[]) public categoryFeedbackIds; // category => array of feedback IDs

    // Events
    event FeedbackSubmitted(
        uint256 indexed feedbackId,
        address indexed submitter,
        FeedbackCategory category,
        string content,
        uint256 timestamp
    );

    event FeedbackVoted(
        uint256 indexed feedbackId,
        address indexed voter,
        VoteType voteType,
        uint256 newUpvotes,
        uint256 newDownvotes
    );

    event FeedbackModerated(uint256 indexed feedbackId, address indexed moderator, bool isActive, string reason);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier validFeedbackId(uint256 _feedbackId) {
        require(_feedbackId > 0 && _feedbackId <= totalFeedbackCount, "Invalid feedback ID");
        _;
    }

    modifier feedbackExists(uint256 _feedbackId) {
        require(feedbacks[_feedbackId].id != 0, "Feedback does not exist");
        _;
    }

    modifier notVotedBefore(uint256 _feedbackId) {
        require(userVotes[msg.sender][_feedbackId].timestamp == 0, "Already voted on this feedback");
        _;
    }

    // Constructor
    constructor(address _owner) {
        owner = _owner;
        totalFeedbackCount = 0;
        totalVotes = 0;
    }

    /**
     * @dev Submit anonymous feedback
     * @param _content The feedback content
     * @param _category The category of feedback (POSITIVE, CONSTRUCTIVE, IDEAS)
     * @param _metadata Optional metadata for additional context
     */
    function submitFeedback(string memory _content, FeedbackCategory _category, string memory _metadata) public {
        require(bytes(_content).length > 0, "Content cannot be empty");
        require(bytes(_content).length <= 1000, "Content too long (max 1000 chars)");
        require(bytes(_metadata).length <= 200, "Metadata too long (max 200 chars)");

        totalFeedbackCount++;
        uint256 feedbackId = totalFeedbackCount;

        feedbacks[feedbackId] = Feedback({
            id: feedbackId,
            content: _content,
            category: _category,
            submitter: msg.sender,
            timestamp: block.timestamp,
            upvotes: 0,
            downvotes: 0,
            isActive: true,
            metadata: _metadata
        });

        // Add to user's feedback list
        userFeedbackIds[msg.sender].push(feedbackId);

        // Add to category list
        categoryFeedbackIds[_category].push(feedbackId);

        emit FeedbackSubmitted(feedbackId, msg.sender, _category, _content, block.timestamp);

        console.log("Feedback submitted with ID:", feedbackId);
    }

    /**
     * @dev Vote on feedback (upvote or downvote)
     * @param _feedbackId The ID of the feedback to vote on
     * @param _voteType The type of vote (UPVOTE or DOWNVOTE)
     */
    function voteOnFeedback(
        uint256 _feedbackId,
        VoteType _voteType
    ) public validFeedbackId(_feedbackId) feedbackExists(_feedbackId) notVotedBefore(_feedbackId) {
        require(feedbacks[_feedbackId].isActive, "Feedback is not active");

        // Record the vote
        userVotes[msg.sender][_feedbackId] = Vote({ voteType: _voteType, timestamp: block.timestamp });

        // Update vote counts
        if (_voteType == VoteType.UPVOTE) {
            feedbacks[_feedbackId].upvotes++;
        } else {
            feedbacks[_feedbackId].downvotes++;
        }

        totalVotes++;

        emit FeedbackVoted(
            _feedbackId,
            msg.sender,
            _voteType,
            feedbacks[_feedbackId].upvotes,
            feedbacks[_feedbackId].downvotes
        );

        console.log("Vote cast on feedback ID:", _feedbackId);
    }

    /**
     * @dev Get feedback by ID
     * @param _feedbackId The ID of the feedback
     * @return The feedback struct
     */
    function getFeedback(
        uint256 _feedbackId
    ) public view validFeedbackId(_feedbackId) feedbackExists(_feedbackId) returns (Feedback memory) {
        return feedbacks[_feedbackId];
    }

    /**
     * @dev Get all feedback IDs for a specific category
     * @param _category The category to filter by
     * @return Array of feedback IDs in that category
     */
    function getFeedbackIdsByCategory(FeedbackCategory _category) public view returns (uint256[] memory) {
        return categoryFeedbackIds[_category];
    }

    /**
     * @dev Get feedback IDs submitted by a specific user
     * @param _user The user address
     * @return Array of feedback IDs submitted by the user
     */
    function getUserFeedbackIds(address _user) public view returns (uint256[] memory) {
        return userFeedbackIds[_user];
    }

    /**
     * @dev Get the latest feedback IDs (for pagination)
     * @param _limit Maximum number of feedback IDs to return
     * @param _offset Number of feedback IDs to skip
     * @return Array of latest feedback IDs
     */
    function getLatestFeedbackIds(uint256 _limit, uint256 _offset) public view returns (uint256[] memory) {
        require(_limit > 0 && _limit <= 100, "Invalid limit (1-100)");

        uint256 start = totalFeedbackCount > _offset ? totalFeedbackCount - _offset : 0;
        uint256 end = start > _limit ? start - _limit : 0;
        uint256 resultLength = start - end;

        uint256[] memory result = new uint256[](resultLength);

        for (uint256 i = 0; i < resultLength; i++) {
            result[i] = start - i;
        }

        return result;
    }

    /**
     * @dev Get feedback statistics
     * @return totalFeedback Total number of feedback submissions
     * @return totalVoteCount Total number of votes cast
     * @return activeFeedback Number of active feedback items
     */
    function getStats() public view returns (uint256 totalFeedback, uint256 totalVoteCount, uint256 activeFeedback) {
        totalFeedback = totalFeedbackCount;
        totalVoteCount = totalVotes;

        // Count active feedback
        for (uint256 i = 1; i <= totalFeedbackCount; i++) {
            if (feedbacks[i].isActive) {
                activeFeedback++;
            }
        }
    }

    /**
     * @dev Moderate feedback (owner only)
     * @param _feedbackId The ID of the feedback to moderate
     * @param _isActive Whether to activate or deactivate the feedback
     * @param _reason Reason for moderation
     */
    function moderateFeedback(
        uint256 _feedbackId,
        bool _isActive,
        string memory _reason
    ) public onlyOwner validFeedbackId(_feedbackId) feedbackExists(_feedbackId) {
        feedbacks[_feedbackId].isActive = _isActive;

        emit FeedbackModerated(_feedbackId, msg.sender, _isActive, _reason);

        console.log("Feedback moderated:", _feedbackId, _isActive);
    }

    /**
     * @dev Check if a user has voted on a specific feedback
     * @param _user The user address
     * @param _feedbackId The feedback ID
     * @return hasVoted Whether the user has voted
     * @return voteType The type of vote if they have voted
     */
    function hasUserVoted(address _user, uint256 _feedbackId) public view returns (bool hasVoted, VoteType voteType) {
        Vote memory vote = userVotes[_user][_feedbackId];
        hasVoted = vote.timestamp > 0;
        if (hasVoted) {
            voteType = vote.voteType;
        }
    }

    /**
     * @dev Get top feedback by votes (upvotes - downvotes)
     * @param _limit Maximum number of feedback to return
     * @return Array of feedback IDs sorted by net votes
     */
    function getTopFeedback(uint256 _limit) public view returns (uint256[] memory) {
        require(_limit > 0 && _limit <= 50, "Invalid limit (1-50)");

        // Create array of all feedback IDs with their net scores
        uint256[] memory allIds = new uint256[](totalFeedbackCount);
        int256[] memory scores = new int256[](totalFeedbackCount);

        for (uint256 i = 1; i <= totalFeedbackCount; i++) {
            if (feedbacks[i].isActive) {
                allIds[i - 1] = i;
                scores[i - 1] = int256(feedbacks[i].upvotes) - int256(feedbacks[i].downvotes);
            }
        }

        // Simple bubble sort (for small datasets)
        for (uint256 i = 0; i < totalFeedbackCount - 1; i++) {
            for (uint256 j = 0; j < totalFeedbackCount - i - 1; j++) {
                if (scores[j] < scores[j + 1]) {
                    // Swap IDs
                    uint256 tempId = allIds[j];
                    allIds[j] = allIds[j + 1];
                    allIds[j + 1] = tempId;

                    // Swap scores
                    int256 tempScore = scores[j];
                    scores[j] = scores[j + 1];
                    scores[j + 1] = tempScore;
                }
            }
        }

        // Return top _limit results
        uint256 resultLength = _limit < totalFeedbackCount ? _limit : totalFeedbackCount;
        uint256[] memory result = new uint256[](resultLength);

        for (uint256 i = 0; i < resultLength; i++) {
            result[i] = allIds[i];
        }

        return result;
    }

    /**
     * @dev Function to receive ETH
     */
    receive() external payable {}
}
